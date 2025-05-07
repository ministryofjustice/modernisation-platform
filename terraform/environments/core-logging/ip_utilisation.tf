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
  function_name                  = "IPUsageMonitoringFunction"
  role                           = aws_iam_role.ip_usage_lambda_exec.arn
  handler                        = "ip_usage_metrics.lambda_handler"
  runtime                        = "python3.11"
  reserved_concurrent_executions = 1

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

# KMS key for Lambda encryption
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

# KMS Alias for the key
resource "aws_kms_alias" "ip_usage" {
  name          = "alias/ip-usage-lambda"
  target_key_id = aws_kms_key.ip_usage.key_id
}

# Add KMS permissions to Lambda execution role
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