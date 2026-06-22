data "aws_kms_alias" "general_hmpps" {
  name = "alias/general-hmpps"
}

module "s3-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=76321e50b20f5c0d918cd45bdcf0b62049f5baf1" # v10.1.0

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }
  bucket_prefix       = "mod-platform-image-artefact-bucket"
  bucket_policy       = [data.aws_iam_policy_document.bucket_policy.json]
  replication_enabled = false
  versioning_enabled  = true
  force_destroy       = false
  ownership_controls  = "BucketOwnerEnforced"
  sse_algorithm       = "aws:kms"
  custom_kms_key      = data.aws_kms_alias.general_hmpps.target_key_arn
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
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=76321e50b20f5c0d918cd45bdcf0b62049f5baf1" # v10.1.0

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }

  bucket_prefix               = "modernisation-platform-software"
  bucket_policy               = [data.aws_iam_policy_document.software_bucket_policy.json]
  sse_algorithm               = "aws:kms"
  custom_kms_key              = aws_kms_key.software_bucket.arn
  enforce_kms_request_headers = false
  replication_enabled         = false
  versioning_enabled          = true
  force_destroy               = false

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
  description             = "KMS key for Modernisation Platform software bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowOrganisationPrincipalsToUseKey"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          "ForAnyValue:StringLike" = {
            "aws:PrincipalOrgPaths" = [
              "${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"
            ]
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_kms_alias" "software_bucket" {
  name          = "alias/modernisation-platform-software-bucket"
  target_key_id = aws_kms_key.software_bucket.key_id
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
