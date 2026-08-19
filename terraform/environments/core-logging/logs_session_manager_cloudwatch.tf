# CloudWatch Logs destination for cross-account Session Manager transcript log delivery
resource "aws_cloudwatch_log_destination" "session_manager_logs" {
  name       = "session-manager-logs-destination"
  role_arn   = aws_iam_role.cwl_to_firehose_session_manager.arn
  target_arn = aws_kinesis_firehose_delivery_stream.session_manager_logs_to_s3.arn

  depends_on = [
    aws_kinesis_firehose_delivery_stream.session_manager_logs_to_s3,
    aws_iam_role_policy.cwl_to_firehose_policy_session_manager
  ]
}

# Allows all member accounts in the MP organisation to use this destination
resource "aws_cloudwatch_log_destination_policy" "session_manager_logs" {
  destination_name = aws_cloudwatch_log_destination.session_manager_logs.name

  access_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "logs:PutSubscriptionFilter",
      Resource  = aws_cloudwatch_log_destination.session_manager_logs.arn,
      Condition = {
        StringEquals = {
          "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
        }
      }
    }]
  })
}

resource "aws_iam_role" "cwl_to_firehose_session_manager" {
  name = "CWLtoFirehoseRoleSessionManager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Effect = "Allow",
      Principal : {
        Service = "logs.amazonaws.com"
      },
      Action : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "cwl_to_firehose_policy_session_manager" {
  name = "Permissions-Policy-For-CWL-SessionManager"
  role = aws_iam_role.cwl_to_firehose_session_manager.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Effect   = "Allow",
      Action   = ["firehose:PutRecord", "firehose:PutRecordBatch"],
      Resource = [aws_kinesis_firehose_delivery_stream.session_manager_logs_to_s3.arn]
    }]
  })
}
