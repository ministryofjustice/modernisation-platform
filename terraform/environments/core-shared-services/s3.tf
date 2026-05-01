module "s3-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=479b926"

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }
  bucket_prefix       = "mod-platform-image-artefact-bucket"
  bucket_policy       = [data.aws_iam_policy_document.bucket_policy.json]
  replication_enabled = false
  versioning_enabled  = true
  force_destroy       = false
  ownership_controls  = "BucketOwnerEnforced"
  custom_kms_key      = aws_kms_key.s3.arn
  sse_algorithm       = "aws:kms"
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

resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.s3_kms_key_policy.json
}

data "aws_iam_policy_document" "s3_kms_key_policy" {

  # Root account full access (standard)
  statement {
    sid    = "EnableIAMPermissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Allow org users to use the key via S3
  statement {
    sid    = "AllowS3UseOfKey"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    # Match your bucket policy org restriction
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values = [
        "${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"
      ]
    }

    # Only allow usage via S3
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketOwnershipControls"
    ]

    resources = [
      "${module.s3-bucket.bucket.arn}/*",
      module.s3-bucket.bucket.arn
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


module "s3-software-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=479b926"

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }
  bucket_prefix       = "modernisation-platform-software"
  bucket_policy       = [data.aws_iam_policy_document.software_bucket_policy.json]
  replication_enabled = false
  versioning_enabled  = true
  force_destroy       = false
  custom_kms_key      = aws_kms_key.software_bucket.arn
  sse_algorithm       = "aws:kms"
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

resource "aws_kms_key" "software_bucket" {
  description             = "KMS key for software S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.software_bucket_kms_key_policy.json
}


data "aws_iam_policy_document" "software_bucket_kms_key_policy" {
  statement {
    sid    = "EnableIAMPermissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowS3UseOfKey"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values = [
        "${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "software_bucket_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectACL",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectACL"
    ]

    resources = [
      "${module.s3-software-bucket.bucket.arn}/*",
      module.s3-software-bucket.bucket.arn
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
