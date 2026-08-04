## Terraform to Create Central AWS Transform Resources in core-shared-services

# NOTE: SSO group access (application-level assignment) and workspace-level role mappings
# are not managed here. AWS Transform has no public API/CLI for workspace role mappings,
# so that step must be done manually in the Transform console — which means managing the
# application-level SSO assignment in Terraform would just be a second, driftable source of
# truth for the same access. Both are handled manually via the console instead.

locals {
  aws_transform_url = data.aws_secretsmanager_secret_version.aws_transform_url.secret_string
}

data "aws_secretsmanager_secret" "aws_transform_url" {
  name = aws_secretsmanager_secret.aws_transform_url.name
}

data "aws_secretsmanager_secret_version" "aws_transform_url" {
  secret_id = data.aws_secretsmanager_secret.aws_transform_url.id
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

  statement {
    sid    = "AllowSecretsManagerToUseKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext"
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.eu-west-2.amazonaws.com"]
    }
  }
}

resource "aws_secretsmanager_secret" "aws_transform_url" {
  #checkov:skip=CKV2_AWS_57: Secret rotation is managed outside Terraform for this value
  name        = "aws_transform_url"
  description = "AWS Transform workspace URL"
  kms_key_id  = aws_kms_key.transform_bucket.arn
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "aws_transform_url" {
  #checkov:skip=CKV_SECRET_6: Seeded placeholder value is not a real secret; actual value is set outside Terraform
  secret_id     = aws_secretsmanager_secret.aws_transform_url.id
  #checkov:skip=CKV_SECRET_6: Seeded placeholder value is not a real secret; actual value is set outside Terraform
  secret_string = "not-a-real-secret-value"
  lifecycle {
    ignore_changes = [
      # Secret value is set/updated outside Terraform.
      secret_string,
    ]
  }
}
