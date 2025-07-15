
data "aws_kms_key" "laa_general" {
  key_id = "arn:aws:kms:eu-west-2:${local.environment_management.account_ids["core-shared-services-production"]}:alias/general-laa"
}

locals {

  laa_general_kms_arn = data.aws_kms_key.laa_general.arn

  laa_account_ids = [
    for member in local.environment.members :
    local.environment_management.account_ids[member.account_name]
    if member.business_unit == "laa"
  ]

}


module "laa-shared-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=9facf9fc8f8b8e3f93ffbda822028534b9a75399" # v9.0.0

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }
  bucket_prefix       = "modernisation-platform-laa-shared"
  bucket_policy       = [data.aws_iam_policy_document.laa_shared_bucket_policy.json]
  replication_enabled = false
  versioning_enabled  = true
  force_destroy       = false
  ownership_controls  = "BucketOwnerEnforced"
  custom_kms_key      = local.laa_general_kms_arn

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


data "aws_iam_policy_document" "laa_shared_bucket_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:GetBucketOwnershipControls"
    ]

    resources = [
      module.laa-shared-bucket.bucket.arn,
      "${module.laa-shared-bucket.bucket.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = local.laa_account_ids
    }
  }
}
