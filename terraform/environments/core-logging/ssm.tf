resource "aws_ssm_parameter" "cortex_account_id" {
  #checkov:skip=CKV2_AWS_34: "Parameter is not sensitive; account ID is publicly available."
  lifecycle {
    ignore_changes = [value]
  }
  provider       = aws.modernisation-platform
  description    = "Account ID for Palo Alto Cortex XSIAM cross-account role."
  name           = "cortex_account_id"
  type           = "String"
  insecure_value = "Placeholder"
  tags           = local.tags
}

resource "aws_ssm_parameter" "core_logging_bucket_arns" {
  #checkov:skip=CKV2_AWS_34: "Parameter is not sensitive; bucket ARNs are stored here for programmatic retrieval."
  provider    = aws.modernisation-platform
  description = "Bucket ARNs in core-logging for Palo Alto Cortex XSIAM."
  name        = "core_logging_bucket_arns"
  type        = "String"
  insecure_value = jsonencode({
    for key in local.cortex_logging_buckets :
    key => aws_s3_bucket.logging[key].arn
  })
  tags = local.tags
}
