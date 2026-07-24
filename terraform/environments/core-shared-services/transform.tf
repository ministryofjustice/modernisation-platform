## Terraform to Create Central AWS Transform Resources in core-shared-services

# SSM parameters to hold the Transform Resource ARNs
#
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

# Central S3 as used in Transform Hub Configuration

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
