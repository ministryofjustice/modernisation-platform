# Lambda function to publish metrics for IP usage in subnets across core-vpc accounts and alert when utilisation is high
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

resource "aws_iam_policy" "ip_usage_cloudwatch_metrics" {
  name        = "LambdaCloudWatchMetricsPolicy"
  description = "Allows publishing CloudWatch metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ip_usage_cloudwatch_metrics" {
  role       = aws_iam_role.ip_usage_lambda_exec.name
  policy_arn = aws_iam_policy.ip_usage_cloudwatch_metrics.arn

}

locals {
  core_vpc_accounts = [
    for key, value in local.environment_management.account_ids :
    value if can(regex("^core-vpc-", key))
  ]
}

resource "aws_iam_policy" "assume_target_roles" {
  name        = "AssumeTargetRolesPolicy"
  description = "Policy allowing Lambda to assume roles in core-vpc accounts"
  policy      = data.aws_iam_policy_document.assume_target_roles.json
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

resource "aws_iam_role_policy_attachment" "assume_target_roles" {
  role       = aws_iam_role.ip_usage_lambda_exec.name
  policy_arn = aws_iam_policy.assume_target_roles.arn
}

data "archive_file" "ip_usage_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/ip_utilisation"
  output_path = "${path.module}/lambda/ip_usage_lambda.zip"
}

resource "aws_lambda_function" "ip_usage" {
  # checkov:skip=CKV_AWS_50: "X-ray tracing is not required"
  # checkov:skip=CKV_AWS_117: "Lambda is not environment specific"
  # checkov:skip=CKV_AWS_116: "DLQ not required"
  # checkov:skip=CKV_AWS_272: "Code signing not required"
  function_name                  = "ip_usage_monitoring"
  role                           = aws_iam_role.ip_usage_lambda_exec.arn
  handler                        = "ip_usage_metrics.lambda_handler"
  runtime                        = "python3.11"
  reserved_concurrent_executions = 1
  timeout                        = 300

  filename         = data.archive_file.ip_usage_lambda.output_path
  source_code_hash = data.archive_file.ip_usage_lambda.output_base64sha256

  kms_key_arn = aws_kms_key.ip_usage.arn

  environment {
    variables = {
      ASSUME_ROLE_NAME = "IPUsageMetricsReadRole"
      TARGET_ACCOUNTS  = join(",", local.core_vpc_accounts)
      AWS_RESERVED_IPS = "5"
      METRIC_NAMESPACE = "Custom/SubnetInfo"
    }
  }
}
resource "aws_cloudwatch_event_rule" "ip_usage_schedule" {
  name                = "ip-usage-schedule"
  description         = "Trigger IP Usage Lambda every 1 day"
  schedule_expression = "cron(0 10 * * ? *)" # run daily at 10:00 UTC
}

resource "aws_cloudwatch_event_target" "ip_usage_lambda_target" {
  rule      = aws_cloudwatch_event_rule.ip_usage_schedule.name
  target_id = "ip-usage-lambda"
  arn       = aws_lambda_function.ip_usage.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ip_usage.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ip_usage_schedule.arn
}

resource "aws_kms_key" "ip_usage" {
  description             = "KMS key for IP Usage Lambda encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Lambda to decrypt"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ip_usage_lambda_exec.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "ip-usage-lambda"
  }
}

resource "aws_kms_alias" "ip_usage" {
  name          = "alias/ip-usage-lambda"
  target_key_id = aws_kms_key.ip_usage.key_id
}

data "aws_iam_policy_document" "ip_usage_kms" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.ip_usage.arn]
  }
}

resource "aws_iam_role_policy" "ip_usage_kms" {
  name   = "ip-usage-kms-decrypt"
  role   = aws_iam_role.ip_usage_lambda_exec.name
  policy = data.aws_iam_policy_document.ip_usage_kms.json
}

resource "aws_kms_key" "ip_usage_sns_encryption" {
  description             = "KMS key for SNS topic encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow SNS to use the key",
        Effect = "Allow",
        Principal = {
          Service = "sns.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "sns-encryption-key"
  }
}
resource "aws_kms_alias" "ip_usage_sns_topic" {
  name_prefix   = "alias/ip-usage-sns-encryption"
  target_key_id = aws_kms_key.ip_usage_sns_encryption.key_id
}

resource "aws_sns_topic" "ip_usage_alerts" {
  name              = "subnet-utilisation-alerts"
  kms_master_key_id = aws_kms_key.ip_usage_sns_encryption.arn
}

resource "aws_cloudwatch_metric_alarm" "ip_usage_high" {
  alarm_name          = "SubnetUtilisationHigh"
  alarm_description   = "Triggers when any subnet reaches 90% utilisation within a 1-day period"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 86400 # 1 day in seconds
  threshold           = 70
  statistic           = "Average"

  metric_name = "SubnetUtilization"
  namespace   = "Custom/SubnetInfo"

  # Open filter for all subnets
  dimensions = {}

  alarm_actions = [
    aws_sns_topic.ip_usage_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.ip_usage_alerts.arn
  ]

  insufficient_data_actions = [
    aws_sns_topic.ip_usage_alerts.arn
  ]
}

module "ip-usage-chatbot" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-aws-chatbot?ref=73280f80ce8a4557cec3a76ee56eb913452ca9aa" // v2.0.0

  slack_channel_id = "C02PFCG8M1R" // #modernisation-platform-low-priority-alerts
  sns_topic_arns   = ["arn:aws:sns:eu-west-2:${local.environment_management.account_ids[terraform.workspace]}:${aws_sns_topic.ip_usage_alerts.name}"]
  tags             = local.tags
  application_name = local.application_name
}