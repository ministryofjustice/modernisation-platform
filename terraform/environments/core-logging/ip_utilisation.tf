# Lambda function to check IP usage in subnets across core-vpc accounts
resource "aws_iam_role" "ip_usage_lambda_exec" {
  name = "IPUsageLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "ip_usage_lambda_exec" {
  name       = "attach-basic-lambda-exec"
  roles      = [aws_iam_role.ip_usage_lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

locals {
  core_vpc_accounts = [
    for key, value in local.environment_management.account_ids :
    value if can(regex("^core-vpc-", key))
  ]
}

data "aws_iam_policy_document" "assume_target_roles" {
  dynamic "statement" {
    for_each = local.core_vpc_accounts
    content {
      effect    = "Allow"
      actions   = ["sts:AssumeRole"]
      resources = ["arn:aws:iam::${statement.value}:role/IPUsageMetricsReadRole"]
    }
  }
}

data "archive_file" "ip_usage_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/ip_utilisation"
  output_path = "${path.module}/lambda/ip_usage_lambda.zip"
}

resource "aws_lambda_function" "ip_usage" {
  function_name = "IPUsageMonitoringFunction"
  role          = aws_iam_role.ip_usage_lambda_exec.arn
  handler       = "ip_usage_metrics.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.ip_usage_lambda.output_path
  source_code_hash = data.archive_file.ip_usage_lambda.output_base64sha256

  environment {
    variables = {
      ASSUME_ROLE_NAME = "IPUsageMetricsReadRole"
      TARGET_ACCOUNTS  = join(",", local.core_vpc_accounts)
      AWS_RESERVED_IPS = "5"
      METRIC_NAMESPACE = "Custom/SubnetInfo"
    }
  }
}