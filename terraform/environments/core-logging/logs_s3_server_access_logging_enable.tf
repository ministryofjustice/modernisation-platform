resource "aws_s3_bucket_logging" "vpc_and_r53_resolver" {
  for_each = toset(["vpc-flow-logs", "r53-resolver-logs"])

  bucket        = aws_s3_bucket.logging[each.key].id
  target_bucket = module.s3-bucket-core-logging-s3-server-access-logs.bucket.id
  target_prefix = "s3-access/${aws_s3_bucket.logging[each.key].bucket}/"
}
