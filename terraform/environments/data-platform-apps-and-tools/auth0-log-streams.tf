resource "auth0_log_stream" "aws_eventbridge" {
  name   = "AWS Eventbridge"
  type   = "eventbridge"
  status = "active"

  sink {
    aws_account_id = data.aws_caller_identity.current.account_id
    aws_region     = data.aws_region.current.name
  }
}