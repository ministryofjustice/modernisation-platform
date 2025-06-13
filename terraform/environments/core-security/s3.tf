# checkov:skip=CKV2_AWS_6   Public access is blocked by default, enforced via org SCPs
# checkov:skip=CKV2_AWS_62  No event notification needed for static JSON archive
# checkov:skip=CKV_AWS_18   Logging unnecessary for low-risk Route53 data
# checkov:skip=CKV_AWS_145  Default encryption is sufficient, no KMS needed
# checkov:skip=CKV_AWS_144  Cross-region replication not required
# checkov:skip=CKV_AWS_21   Versioning not needed for overwrite-safe JSON
# checkov:skip=CKV2_AWS_61  No lifecycle needed for now

resource "aws_s3_bucket" "route53_data" {
  bucket = "modernisation-platform-route53-data"
}