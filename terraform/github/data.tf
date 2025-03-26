data "aws_caller_identity" "testing_test" {
  provider = aws.testing-test
}

data "aws_caller_identity" "modernisation_platform" {
}

data "aws_kms_key" "s3_state_bucket_multi_region" {
  key_id = "alias/s3-state-bucket-multi-region"
}

data "aws_kms_key" "environment_management_multi_region" {
  key_id = "alias/environment-management-multi-region"
}

data "aws_kms_key" "pagerduty_multi_region" {
  key_id = "alias/pagerduty-secret-multi-region"
}
