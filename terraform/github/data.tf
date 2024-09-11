data "github_repositories" "modernisation-platform-repositories" {
  query = "org:ministryofjustice archived:false modernisation-platform"
  sort  = "stars"
}

data "aws_caller_identity" "testing_test" {
  provider = aws.testing-test

}

data "aws_caller_identity" "modernisation_platform" {

}

data "aws_kms_key" "s3_state_bucket" {
  key_id = "alias/s3-state-bucket-multi-region"
}

data "aws_kms_key" "dynamodb_state_lock" {
  key_id = "alias/dynamodb-state-lock-multi-region"
}

data "aws_kms_key" "environment_management" {
  key_id = "alias/environment-management-multi-region"
}

data "aws_kms_key" "pagerduty" {
  key_id = "alias/pagerduty-secret-multi-region"
}