data "aws_ssm_parameter" "core_logging_bucket_arns" {
  provider = aws.modernisation-platform
  name     = "core_logging_bucket_arns"
}

data "aws_ssm_parameter" "cortex_xsiam_endpoint" {
  provider = aws.modernisation-platform
  name     = "cortex_xsiam_endpoint"
}
