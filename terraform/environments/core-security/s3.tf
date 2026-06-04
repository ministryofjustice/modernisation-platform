# TFSec ignores:
# - AWS002: Ignore warnings regarding lack of s3 bucket server access logging - considered overkill given bucket purpose and restricted access to bucket
#tfsec:ignore:AWS098 tfsec:ignore:AWS002 tfsec:ignore:aws-s3-block-public-acls tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "route53_data" {
  # checkov:skip=CKV2_AWS_6   Public access is blocked by default, enforced via org SCPs
  # checkov:skip=CKV2_AWS_62  No event notification needed for static JSON archive
  # checkov:skip=CKV_AWS_18   Logging unnecessary for low-risk Route53 data
  # checkov:skip=CKV_AWS_145  Default encryption is sufficient, no KMS needed
  # checkov:skip=CKV_AWS_144  Cross-region replication not required
  # checkov:skip=CKV_AWS_21   Versioning not needed for overwrite-safe JSON
  # checkov:skip=CKV2_AWS_61  No lifecycle needed for now
  bucket = "modernisation-platform-route53-data"
}

resource "aws_s3_bucket_public_access_block" "route53_data" {
  bucket                  = aws_s3_bucket.route53_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}