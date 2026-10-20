# CloudWatch Logs Destination for cross-account log delivery
resource "aws_cloudwatch_log_destination" "waf_logs" {
  name       = "waf-logs-destination"
  role_arn   = aws_iam_role.cwl_to_firehose.arn
  target_arn = aws_kinesis_firehose_delivery_stream.waf_logs_to_s3.arn

  depends_on = [
    aws_kinesis_firehose_delivery_stream.waf_logs_to_s3,
    aws_iam_role_policy.cwl_to_firehose_policy
  ]
}

# Allows all member accounts to use this destination
resource "aws_cloudwatch_log_destination_policy" "waf_logs" {
  destination_name = aws_cloudwatch_log_destination.waf_logs.name
  access_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "logs:PutSubscriptionFilter",
      Resource  = aws_cloudwatch_log_destination.waf_logs.arn,
      Condition = {
        StringEquals = {
          "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
        }
      }
    }]
  })
}


resource "aws_iam_role" "cwl_to_firehose" {
  name = "CWLtoFirehoseRole"

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

resource "aws_iam_role_policy" "cwl_to_firehose_policy" {
  name = "Permissions-Policy-For-CWL"
  role = aws_iam_role.cwl_to_firehose.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Effect   = "Allow",
      Action   = ["firehose:*"],
      Resource = [aws_kinesis_firehose_delivery_stream.waf_logs_to_s3.arn]
    }]
  })
}
