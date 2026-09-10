module "s3-bucket-cloudtrail" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=66bd5c6aa0d0396442f0d4a63642029ff38d2a8a" # v11.1.0
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy                = [data.aws_iam_policy_document.cloudtrail_bucket_policy.json]
  bucket_name                  = "modernisation-platform-logs-cloudtrail"
  replication_bucket           = "modernisation-platform-logs-cloudtrail-replication"
  sse_algorithm                = "aws:kms"
  suffix_name                  = "-cloudtrail"
  custom_kms_key               = aws_kms_key.s3_logging_cloudtrail.arn
  custom_replication_kms_key   = aws_kms_key.s3_logging_cloudtrail_eu-west-1_replication.arn
  replication_enabled          = true
  replication_metrics_enabled  = true
  replication_object_lock_days = 7
  replication_region           = "eu-west-1"
  ownership_controls           = "BucketOwnerEnforced"
  tags = merge(local.tags, {
    backup = "false"
  })
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid       = "AllowCloudTrailPutObjectWithinOrg"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.s3-bucket-cloudtrail.bucket.arn}/*", module.s3-bucket-cloudtrail.bucket.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = [data.aws_organizations_organization.moj_root_account.id]
    }
  }
  statement {
    sid       = "AllowCloudTrailGetBucketAcl"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [module.s3-bucket-cloudtrail.bucket.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}
