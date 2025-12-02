locals {
  github_workflow_poller = {
    enabled             = true
    github_owner        = "ministryofjustice"
    github_repo         = "modernisation-platform"
    lookback_hours      = 2
    schedule_expression = "cron(0/15 * * * ? *)"
    log_retention_days  = 90
  }
}

resource "aws_cloudwatch_log_group" "github_workflow_data" {
  #checkov:skip=CKV_AWS_338: Logs can be retained for less than 1 year.
  #checkov:skip=CKV_AWS_158: Log does not contain sensitive data.
  count             = local.github_workflow_poller.enabled ? 1 : 0
  name              = "modernisation-platform-workflow-data"
  retention_in_days = local.github_workflow_poller.log_retention_days

  tags = merge(
    local.tags,
    {
      Name = "modernisation-platform-workflow-data"
    }
  )
}

resource "aws_cloudwatch_log_group" "github_workflow_poller_lambda" {
  #checkov:skip=CKV_AWS_338: Logs can be retained for less than 1 year.
  #checkov:skip=CKV_AWS_158: Log does not contain sensitive data.
  count             = local.github_workflow_poller.enabled ? 1 : 0
  name              = "/aws/lambda/github-workflow-data-poller"
  retention_in_days = local.github_workflow_poller.log_retention_days

  tags = merge(
    local.tags,
    {
      Name = "github-workflow-data-poller-logs"
    }
  )
}

resource "aws_iam_role" "github_workflow_poller_lambda" {
  count = local.github_workflow_poller.enabled ? 1 : 0
  name  = "github-workflow-data-poller-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "github_workflow_poller_lambda" {
  count = local.github_workflow_poller.enabled ? 1 : 0
  name  = "github-workflow-data-poller-lambda-policy"
  role  = aws_iam_role.github_workflow_poller_lambda[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.github_workflow_poller_lambda[0].arn}:*",
          "${aws_cloudwatch_log_group.github_workflow_data[0].arn}:*"
        ]
      }
    ]
  })
}

data "archive_file" "github_workflow_poller_lambda" {
  count       = local.github_workflow_poller.enabled ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/lambda/github_workflow_data_poller/github_workflow_data_poller.py"
  output_path = "${path.module}/lambda/github_workflow_data_poller/lambda.zip"
}

resource "aws_lambda_function" "github_workflow_data_poller" {
  #checkov:skip=CKV_AWS_272: Does not require code signing.
  #checkov:skip=CKV_AWS_173: Does not have sensitive environment variables.
  #checkov:skip=CKV_AWS_50: No x-ray tracing needed.
  #checkov:skip=CKV_AWS_116: Dead Letter Queue not needed.
  #checkov:skip=CKV_AWS_117: Lambda not deployed in a VPC.
  count                   = local.github_workflow_poller.enabled ? 1 : 0
  filename                = data.archive_file.github_workflow_poller_lambda[0].output_path
  function_name           = "github-workflow-data-poller"
  role                    = aws_iam_role.github_workflow_poller_lambda[0].arn
  handler                 = "github_workflow_data_poller.lambda_handler"
  source_code_hash        = data.archive_file.github_workflow_poller_lambda[0].output_base64sha256
  runtime                 = "python3.12"
  timeout                 = 300
  description             = "Polls GitHub Actions workflow data and writes to CloudWatch Logs"
  reserved_concurrent_executions  = 10

  environment {
    variables = {
      GITHUB_OWNER           = local.github_workflow_poller.github_owner
      GITHUB_REPO            = local.github_workflow_poller.github_repo
      LOOKBACK_HOURS         = local.github_workflow_poller.lookback_hours
      WORKFLOW_RUN_LOG_GROUP = aws_cloudwatch_log_group.github_workflow_data[0].name
      GITHUB_TOKEN           = ""  # Optional: Add if you need authenticated API access
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.github_workflow_poller_lambda,
    aws_iam_role_policy.github_workflow_poller_lambda
  ]

  tags = merge(
    local.tags,
    {
      Name = "github-workflow-data-poller"
    }
  )
}

resource "aws_cloudwatch_event_rule" "github_workflow_poller" {
  count               = local.github_workflow_poller.enabled ? 1 : 0
  name                = "github-workflow-data-poller"
  description         = "Trigger GitHub workflow data poller"
  schedule_expression = local.github_workflow_poller.schedule_expression

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "github_workflow_poller" {
  count = local.github_workflow_poller.enabled ? 1 : 0
  rule  = aws_cloudwatch_event_rule.github_workflow_poller[0].name
  arn   = aws_lambda_function.github_workflow_data_poller[0].arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = local.github_workflow_poller.enabled ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.github_workflow_data_poller[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.github_workflow_poller[0].arn
}