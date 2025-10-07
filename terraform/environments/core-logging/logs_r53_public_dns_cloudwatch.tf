# CloudWatch Logs Destination for cross-account R53 Public DNS log delivery
resource "aws_cloudwatch_log_destination" "r53_public_dns_logs" {
  name       = "r53-public-dns-logs-destination"
  role_arn   = aws_iam_role.cwl_to_firehose_r53_public_dns.arn
  target_arn = aws_kinesis_firehose_delivery_stream.r53_public_dns_logs_to_s3.arn

  depends_on = [
    aws_kinesis_firehose_delivery_stream.r53_public_dns_logs_to_s3,
    aws_iam_role_policy.cwl_to_firehose_policy_r53_public_dns
  ]
}

# Allows all member accounts to use this destination
resource "aws_cloudwatch_log_destination_policy" "r53_public_dns_logs" {
  destination_name = aws_cloudwatch_log_destination.r53_public_dns_logs.name
  access_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "logs:PutSubscriptionFilter",
      Resource  = aws_cloudwatch_log_destination.r53_public_dns_logs.arn,
      Condition = {
        StringLike = {
          "aws:PrincipalOrgPaths" = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
        }
      }
    }]
  })
}

resource "aws_iam_role" "cwl_to_firehose_r53_public_dns" {
  name = "CWLtoFirehoseRoleR53PublicDNS"

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

resource "aws_iam_role_policy" "cwl_to_firehose_policy_r53_public_dns" {
  name = "Permissions-Policy-For-CWL-R53-Public-DNS"
  role = aws_iam_role.cwl_to_firehose_r53_public_dns.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Effect   = "Allow",
      Action   = ["firehose:*"],
      Resource = [aws_kinesis_firehose_delivery_stream.r53_public_dns_logs_to_s3.arn]
    }]
  })
}
