module "s3-bucket-core-logging-s3-server-access-logs" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=9facf9fc8f8b8e3f93ffbda822028534b9a75399" # v9.0.0
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }

  bucket_policy      = [data.aws_iam_policy_document.core_logging_s3_server_access_logs_bucket_policy.json]
  bucket_name        = "modernisation-platform-logs-s3-server-access-logs"
  replication_bucket = "modernisation-platform-logs-s3-server-access-logs-replication"
  suffix_name        = "-s3-server-access-logs"

  # Reuse an existing KMS key if you prefer; otherwise create a new one.
  # This is an example using the same key as cloudtrail logging.
  custom_kms_key             = aws_kms_key.s3_logging_cloudtrail.arn
  custom_replication_kms_key = aws_kms_key.s3_logging_cloudtrail_eu-west-1_replication.arn

  ownership_controls  = "BucketOwnerEnforced"
  replication_enabled = true
  replication_region  = "eu-west-1"

  tags = local.tags
}

data "aws_iam_policy_document" "core_logging_s3_server_access_logs_bucket_policy" {
  statement {
    sid       = "AllowS3ServerAccessLoggingPutObjectFromSourceBucketsWithinAccount"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.s3-bucket-core-logging-s3-server-access-logs.bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    # Allow writes only from our account
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    # Allow only from the specific source buckets we’re enabling logging on
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        # WAF bucket (module-based)
        module.s3-bucket-modernisation-platform-waf-logs.bucket.arn,

        # R53 public DNS bucket (module-based)
        module.s3_bucket_r53_public_dns_logs.bucket.arn,

        # VPC flow logs bucket (raw aws_s3_bucket in logs_s3.tf)
        aws_s3_bucket.logging["vpc-flow-logs"].arn,

        # R53 resolver logs bucket (raw aws_s3_bucket in logs_s3.tf)
        aws_s3_bucket.logging["r53-resolver-logs"].arn,
      ]
    }
  }
}
