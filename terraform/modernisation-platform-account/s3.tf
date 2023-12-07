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
resource "aws_kms_key" "s3_state_bucket_replication" {
  provider = aws.modernisation-platform-eu-west-3

  description             = "s3-state_bucket-${local.backup_region}-replication"
  policy                  = data.aws_iam_policy_document.kms_state_bucket.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "s3_state_bucket_replication" {
  provider = aws.modernisation-platform-eu-west-3

  name          = "alias/s3-state_bucket-${local.backup_region}-replication"
  target_key_id = aws_kms_key.s3_state_bucket_eu-west-3_replication.id
}

module "state-bucket-s3-replication-role" {
  source             = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket-replication-role?ref=3b8a2945c1d266cc0ec2b21edb7f186b6574bda7" # v4.0.0
  buckets            = [module.state-bucket.bucket.arn]
  replication_bucket = "modernisation-platform-terraform-state-replication"
  suffix_name        = "-terraform-state"
  tags               = local.tags
}

module "state-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=8688bc15a08fbf5a4f4eef9b7433c5a417df8df1" # v7.0.0

  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-3
  }
  bucket_policy              = [data.aws_iam_policy_document.allow-state-access-from-root-account.json]
  bucket_name                = "modernisation-platform-terraform-state"
  replication_role_arn       = module.state-bucket-s3-replication-role.role.arn
  replication_enabled        = true
  replication_region         = local.backup_region
  custom_kms_key             = aws_kms_key.s3_state_bucket.arn
  custom_replication_kms_key = aws_kms_key.s3_state_bucket_eu-west-3_replication.arn
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
