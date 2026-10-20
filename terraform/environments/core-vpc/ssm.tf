data "aws_ssm_parameter" "core_logging_bucket_arns" {
  provider = aws.modernisation-platform
  name     = "core_logging_bucket_arns"
}
