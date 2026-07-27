## Terraform to Create Central AWS Transform Resources in core-shared-services

data "aws_ssoadmin_instances" "transform_hub" {
  provider = aws.transform-hub-sso-lookup
}

locals {
  transform_hub_groups_config           = jsondecode(file("${path.module}/transform/sso-groups.json"))
  transform_hub_workspace_access_config = jsondecode(file("${path.module}/transform/workspace-access.json"))

  transform_hub_application_arn   = aws_ssm_parameter.transform_hub_application_arn.value
  transform_hub_profile_arn       = aws_ssm_parameter.transform_hub_profile_arn.value
  transform_hub_identity_store_id = one(data.aws_ssoadmin_instances.transform_hub.identity_store_ids)

  transform_hub_sso_group_names_raw = length(try(local.transform_hub_groups_config.sso_group_names, [])) > 0 ? local.transform_hub_groups_config.sso_group_names : ["transform-admins"]
  transform_hub_sso_group_names     = distinct(compact([for group_name in local.transform_hub_sso_group_names_raw : trimspace(group_name)]))
  transform_hub_workspaces      = try(local.transform_hub_workspace_access_config.workspaces, {})

  transform_hub_workspace_group_pairs = flatten([
    for workspace_name, workspace_config in local.transform_hub_workspaces : [
      for group_mapping in(
        can(workspace_config.group_roles)
        ? [for group_name, workspace_role in workspace_config.group_roles : {
          group_name     = trimspace(group_name)
          workspace_role = workspace_role
        }]
        : [for group_name in workspace_config.sso_group_names : {
          group_name     = trimspace(group_name)
          workspace_role = workspace_config.workspace_role
        }]
      ) : {
        workspace      = workspace_name
        group_name     = trimspace(group_mapping.group_name)
        workspace_role = group_mapping.workspace_role
      }
    ]
  ])

  transform_hub_distinct_group_names = distinct(concat(
    local.transform_hub_sso_group_names,
    [for pair in local.transform_hub_workspace_group_pairs : pair.group_name]
  ))

  transform_hub_user_management_enabled = var.transform_user_management_enabled
}

# Using the plural data source (ListGroups) rather than the singular aws_identitystore_group
# (GetGroupId) data source: GetGroupId consistently returns ResourceNotFoundException for
# these groups via the transform-hub-sso-lookup provider, even with a confirmed-correct,
# exact-match DisplayName. Listing all groups and filtering locally avoids that API call.
data "aws_identitystore_groups" "transform_hub_groups" {
  provider = aws.transform-hub-sso-lookup

  identity_store_id = local.transform_hub_identity_store_id
}

locals {
  transform_hub_group_id_by_name = {
    for group in data.aws_identitystore_groups.transform_hub_groups.groups :
    group.display_name => group.group_id
  }
}

# These parameters are necessary because the AWS Terraform provider (as of v6.x) has limited support
# for AWS Transform resources:
# - The Transform Application can be imported using aws_ssoadmin_application but requires manual import
# - Transform Profiles have NO resource or data source support (aws_transform_profile does not exist)
# - There are no data sources to discover/lookup existing Transform resources dynamically
#
# Therefore, we use SSM parameters to store the ARNs of manually-created Transform resources
# (created via AWS console) and reference them via data lookups. This approach:
# - Avoids hardcoding ARNs in Terraform code
# - Provides a centralized place to manage these values
# - Allows Terraform to reference resources it cannot directly manage

resource "aws_ssm_parameter" "transform_hub_application_arn" {
  #checkov:skip=CKV_AWS_337: "Default SSM encryption is sufficient for storing ARNs"
  name        = "/transform/hub/application-arn"
  description = "Transform Hub Application ARN (manually created via console)"
  type        = "SecureString"
  value       = "PLACEHOLDER" # Set this to the actual ARN after first apply

  lifecycle {
    ignore_changes = [value]
  }

  tags = local.tags
}

resource "aws_ssm_parameter" "transform_hub_profile_arn" {
  #checkov:skip=CKV_AWS_337: "Default SSM encryption is sufficient for storing ARNs"
  name        = "/transform/hub/profile-arn"
  description = "Transform Hub Profile ARN (manually created via console)"
  type        = "SecureString"
  value       = "PLACEHOLDER" # Set this to the actual ARN after first apply

  lifecycle {
    ignore_changes = [value]
  }

  tags = local.tags
}

##Transform Administrator and User Access Management

# Baseline access to open the Transform application for each configured group.
# Workspace-level permissions are applied separately below via role mappings.
resource "aws_ssoadmin_application_assignment" "transform_hub_access" {
  for_each = local.transform_hub_user_management_enabled ? toset(local.transform_hub_distinct_group_names) : toset([])

  application_arn = local.transform_hub_application_arn
  principal_id    = local.transform_hub_group_id_by_name[each.value]
  principal_type  = "GROUP"
}

resource "terraform_data" "transform_hub_workspace_role_mapping" {
  for_each = local.transform_hub_user_management_enabled ? {
    for pair in local.transform_hub_workspace_group_pairs :
    "${pair.workspace}/${pair.group_name}" => pair
  } : {}

  triggers_replace = [
    each.value.workspace,
    each.value.group_name,
    local.transform_hub_group_id_by_name[each.value.group_name],
    each.value.workspace_role,
    local.transform_hub_profile_arn
  ]

  provisioner "local-exec" {
    command = <<-EOT
      aws transform put-user-role-mappings \
        --profile-arn "${local.transform_hub_profile_arn}" \
        --workspace-name "${each.value.workspace}" \
        --principal-id "${local.transform_hub_group_id_by_name[each.value.group_name]}" \
        --principal-type GROUP \
        --role "${each.value.workspace_role}"
    EOT
  }

  depends_on = [aws_ssoadmin_application_assignment.transform_hub_access]
}

# Central S3 as used in Transform Configuration
module "transform_s3_bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=c8889e65f4d8a3d53d2cbd93b7be714e990020b7" # v10.2.1

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }

  bucket_prefix               = "aws-transform-org"
  bucket_policy               = [data.aws_iam_policy_document.transform_s3_bucket_policy.json]
  sse_algorithm               = "aws:kms"
  custom_kms_key              = aws_kms_key.transform_bucket.arn
  enforce_kms_request_headers = true
  replication_enabled         = false
  versioning_enabled          = true
  force_destroy               = false
  ownership_controls          = "BucketOwnerEnforced"

  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"
      prefix  = ""

      tags = {
        rule      = "log"
        autoclean = "true"
      }

      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        days = 730
      }
    }
  ]

  tags = local.tags
}

data "aws_iam_policy_document" "transform_s3_bucket_policy" {
  statement {
    sid    = "AllowTransformAccessToBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      module.transform_s3_bucket.bucket.arn,
      "${module.transform_s3_bucket.bucket.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["transform.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [
        data.aws_caller_identity.current.account_id,
        data.aws_organizations_organization.root_account.master_account_id
      ]
    }
  }
}

resource "aws_kms_key" "transform_bucket" {
  description             = "KMS key for AWS Transform S3 bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.transform_kms_key_policy.json

  tags = local.tags
}

resource "aws_kms_alias" "transform_bucket" {
  name          = "alias/aws-transform-bucket"
  target_key_id = aws_kms_key.transform_bucket.key_id
}

data "aws_iam_policy_document" "transform_kms_key_policy" {

  #checkov:skip=CKV_AWS_109: "Key policy requires asterisk resource"
  #checkov:skip=CKV_AWS_111: "Key policy requires asterisk resource"
  #checkov:skip=CKV_AWS_356: "Key policy requires asterisk resource"

  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"
    actions = [
      "kms:*"
    ]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "AllowTransformToUseKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncrypt*"
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["transform.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [
        data.aws_caller_identity.current.account_id,
        data.aws_organizations_organization.root_account.master_account_id
      ]
    }
  }
}


