# State bucket KMS Source
resource "aws_kms_key" "s3_state_bucket" {
  description             = "s3-state-bucket"
  policy                  = data.aws_iam_policy_document.kms_state_bucket.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "s3_state_bucket" {
  name          = "alias/s3-state-bucket"
  target_key_id = aws_kms_key.s3_state_bucket.id
}

# State bucket KMS multi-Region
resource "aws_kms_key" "s3_state_bucket_multi_region" {
  description             = "s3-state-bucket-multi-region"
  policy                  = data.aws_iam_policy_document.kms_state_bucket.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  multi_region            = true
}

resource "aws_kms_alias" "s3_state_bucket_multi_region" {
  name          = "alias/s3-state-bucket-multi-region"
  target_key_id = aws_kms_key.s3_state_bucket_multi_region.id
}

resource "aws_kms_replica_key" "s3_state_bucket_multi_region_replica" {
  description             = "AWS Secretsmanager CMK replica key"
  deletion_window_in_days = 30
  primary_key_arn         = aws_kms_key.s3_state_bucket_multi_region.arn
  provider                = aws.modernisation-platform-eu-west-1
}

resource "aws_kms_alias" "s3_state_bucket_multi_region_replica" {
  name          = "alias/s3-state-bucket-multi-region-replica"
  target_key_id = aws_kms_replica_key.s3_state_bucket_multi_region_replica.id
}

data "aws_iam_policy_document" "kms_state_bucket" {
  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "role is resticted by limited actions in member account"
  statement {
    sid    = "Allow management access of the key to the modernisation platform account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = concat(
        ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"],
        local.root_users_with_state_access
      )
    }
  }
  statement {
    sid    = "Allow key decryption to STS bucket replication roles"
    effect = "Allow"
    actions = [
      "kms:Decrypt*"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-terraform-state/s3-replication"
      ]
    }
  }
  statement {
    sid    = "ReadOnlyFromModernisationPlatformOU"
    effect = "Allow"
    actions = [
      "kms:Decrypt*"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }
  }
}

# State bucket KMS Destination
resource "aws_kms_key" "s3_state_bucket_eu-west-1_replication" {
  provider = aws.modernisation-platform-eu-west-1

  description             = "s3-state_bucket-eu-west-1-replication"
  policy                  = data.aws_iam_policy_document.kms_state_bucket.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "s3_state_bucket_eu-west-1_replication" {
  provider = aws.modernisation-platform-eu-west-1

  name          = "alias/s3-state_bucket-eu-west-1-replication"
  target_key_id = aws_kms_key.s3_state_bucket_eu-west-1_replication.id
}

module "state-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=cadab519b10a7d28dfa3b77d407725db6b37614a" # v8.0.0

  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy              = [data.aws_iam_policy_document.allow-state-access-from-root-account.json]
  bucket_name                = "modernisation-platform-terraform-state"
  replication_bucket         = "modernisation-platform-terraform-state-replication"
  suffix_name                = "-terraform-state"
  replication_enabled        = true
  replication_region         = "eu-west-1"
  custom_kms_key             = aws_kms_key.s3_state_bucket.arn
  custom_replication_kms_key = aws_kms_key.s3_state_bucket_eu-west-1_replication.arn
  tags                       = local.tags

  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"
      tags    = {}
      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 700
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 730
      }
      noncurrent_version_transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 700
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration = {
        days = 730
      }
    }
  ]
}

# Allow access to the bucket from the MoJ root account
# Policy extrapolated from:
# https://www.terraform.io/docs/backends/types/s3.html#s3-bucket-permissions
data "aws_iam_policy_document" "allow-state-access-from-root-account" {
  statement {
    sid       = "AllowListBucketFromRootAccount"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.state-bucket.bucket.arn]

    principals {
      type        = "AWS"
      identifiers = local.root_users_with_state_access
    }
  }

  statement {
    sid       = "AllowGetObjectsFromRootAccount"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${module.state-bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = local.root_users_with_state_access
    }
  }

  statement {
    sid       = "AllowPutObjectsFromRootAccounts"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.state-bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = local.root_users_with_state_access
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid       = "ListBucketFromModernisationPlatformOU"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.state-bucket.bucket.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }
  }

  statement {
    sid     = "GetObjectFromModernisationPlatformOU"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${module.state-bucket.bucket.arn}/terraform.tfstate",
      "${module.state-bucket.bucket.arn}/environments/members/*",
      "${module.state-bucket.bucket.arn}/environments/accounts/core-network-services/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }
  }

  statement {
    sid     = "AllowTestingCIUser"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${module.state-bucket.bucket.arn}/environments/members/testing/testing-test/terraform.tfstate",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.environment_management.account_ids["testing-test"]}:user/testing-ci"]
    }
  }

  statement {
    sid     = "AllowGithubActionsRole"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${module.state-bucket.bucket.arn}/environments/members/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/github-actions"]
    }
  }

  statement {
    sid       = "AllowAdministratorAccessRole"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.state-bucket.bucket.arn}/environments/members/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_AdministratorAccess_*"]
    }
  }

  statement {
    sid       = "AllowMPAdministratorAccessRole"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.state-bucket.bucket.arn}/environments/accounts/*", ]

    principals {
      type        = "AWS"
      identifiers = tolist(data.aws_iam_roles.sso-admin-access.arns)
    }
  }
}

module "cost-management-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=cadab519b10a7d28dfa3b77d407725db6b37614a" # v8.0.0
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy       = [data.aws_iam_policy_document.cost_management_bucket_policy.json]
  bucket_name         = "mp-cost-explorer-reports"
  custom_kms_key      = aws_kms_key.s3_state_bucket.arn
  replication_enabled = false
  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Disabled"
    }
  ]
  tags = local.tags
}


data "aws_iam_policy_document" "cost_management_bucket_policy" {
  statement {
    sid    = "AllowAdministratorAccessRole"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = ["${module.cost-management-bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.environment_management.modernisation_platform_account_id}:role/github-actions"]
    }
  }
}