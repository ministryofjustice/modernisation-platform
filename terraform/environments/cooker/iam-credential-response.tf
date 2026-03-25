# EventBridge rule — fires when AWS Health detects an exposed IAM key
resource "aws_cloudwatch_event_rule" "iam_credential_exposed" {
  name        = "iam-credential-exposed"
  description = "Triggers on AWS_RISK_CREDENTIALS_EXPOSED Health events"

  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
    detail = {
      service       = ["IAM"]
      eventTypeCode = ["AWS_RISK_CREDENTIALS_EXPOSED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "iam_credential_exposed_lambda" {
  rule      = aws_cloudwatch_event_rule.iam_credential_exposed.name
  target_id = "credential-responder-lambda"
  arn       = aws_lambda_function.credential_responder.arn
}

# Allow EventBridge to invoke the Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.credential_responder.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.iam_credential_exposed.arn
}

# IAM role for the Lambda
resource "aws_iam_role" "credential_responder" {
  name = "credential-responder-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "credential_responder" {
  name = "credential-responder-policy"
  role = aws_iam_role.credential_responder.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DisableAndQuarantineIAM"
        Effect = "Allow"
        Action = [
          "iam:UpdateAccessKey",
          "iam:PutUserPolicy",
          "iam:ListUsers",
          "iam:ListAccessKeys"
        ]
        Resource = "*"
      },
      {
        Sid      = "PublishToSNS"
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.iam_credential_alert.arn
      },
      {
        Sid    = "BasicLambdaLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Lambda function
resource "aws_lambda_function" "credential_responder" {
  function_name    = "iam-credential-responder"
  description      = "Disables exposed IAM keys, quarantines users, and raises alerts via SNS"
  role             = aws_iam_role.credential_responder.arn
  handler          = "credential_responder.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.credential_responder.output_path
  source_code_hash = data.archive_file.credential_responder.output_base64sha256
  timeout          = 60

  environment {
    variables = {
      CREDENTIAL_ALERT_SNS_ARN = aws_sns_topic.iam_credential_alert.arn
    }
  }
}

data "archive_file" "credential_responder" {
  type        = "zip"
  source_file = "${path.module}/lambda/credential_responder.py"
  output_path = "${path.module}/lambda/credential_responder.zip"
}