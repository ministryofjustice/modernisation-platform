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

module "state-bucket-s3-replication-role" {
  source             = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket-replication-role?ref=v3.0.0"
  buckets            = [module.state-bucket.bucket.arn]
  replication_bucket = "modernisation-platform-terraform-state-replication"
  suffix_name        = "-terraform-state"
  tags               = local.tags
}

module "state-bucket" {
  #source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v5.0.1"
  source = "../../../modernisation-platform-terraform-s3-bucket"

  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy              = [data.aws_iam_policy_document.allow-state-access-from-root-account.json]
  bucket_name                = "modernisation-platform-terraform-state"
  replication_role_arn       = module.state-bucket-s3-replication-role.role.arn
  replication_enabled        = true
  replication_region         = "eu-west-1"
  custom_kms_key             = aws_kms_key.s3_state_bucket.arn
  custom_replication_kms_key = aws_kms_key.s3_state_bucket_eu-west-1_replication.arn
  tags                       = local.tags

  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"
      prefix  = ""
      tags    = {}
      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
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
          days          = 365
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
    sid    = "AllowModifyObjectsFromRootAccount"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = ["${module.state-bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = local.root_users_with_state_access
    }
  }

  statement {
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
    sid    = "ReadOnlyFromModernisationPlatformOU"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.state-bucket.bucket.arn,
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
}
