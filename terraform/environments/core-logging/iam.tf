# VPC Flow Log: configure an IAM role
resource "aws_iam_role" "vpc_flow_log" {
  name               = "AWSVPCFlowLog"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_assume_role_policy.json
}

# VPC Flow Log: assume role policy
data "aws_iam_policy_document" "vpc_flow_log_assume_role_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

# VPC Flow Log: publish to CloudWatch
resource "aws_iam_policy" "vpc_flow_log_publish_policy" {
  name   = "AWSVPCFlowLogPublishPolicy"
  policy = data.aws_iam_policy_document.vpc_flow_log_publish_policy.json
}

# Extrapolated from:
# https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html
# tfsec ignore appropriate as wildcard in line with AWS published guidance
# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "vpc_flow_log_publish_policy" {

  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints - This is limited to the log actions only"
  #checkov:skip=CKV_AWS_356: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions - This is limited to the log actions only"
  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"

  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_publish_policy" {
  role       = aws_iam_role.vpc_flow_log.id
  policy_arn = aws_iam_policy.vpc_flow_log_publish_policy.arn
}

# Grafana-Athena Role
resource "aws_iam_role" "grafana_athena" {
  name               = "grafana-athena"
  assume_role_policy = data.aws_iam_policy_document.grafana-athena.json
}

# Grafana-Athena Policy
data "aws_iam_policy_document" "grafana_athena_policy" {
  statement {
    sid    = "s3Access"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      module.s3-grafana-athena-query-results.bucket.arn,
      "${module.s3-grafana-athena-query-results.bucket.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ssm_role.arn]
    }
  }
}

# Attach AmazonGrafanaAthenaAccess policy
resource "aws_iam_role_policy_attachment" "grafana_athena_attachment" {
  role       = aws_iam_role.grafana_athena.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonGrafanaAthenaAccess"
}
