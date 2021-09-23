data "aws_caller_identity" "mod-platform" {
  provider = aws.modernisation-platform
}

#Secrets Manager role
data "aws_iam_policy_document" "lambda_assume_role_policy" {

  provider = aws.modernisation-platform

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/athena_lambda/athena_table_update"]
    }
  }
}

resource "aws_iam_role" "lambda_secretsmanager_access" {

  provider = aws.modernisation-platform

  name = "lambda_secretsmanager_access"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  inline_policy {
    name = "lambda_secretsmanager_access_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect = "Allow"
          Resource = [
            "${data.aws_secretsmanager_secret.environment_management.arn}"
          ]
        },
      ]
    })
  }
}

#S3 Bucket for Athena temp SQL queries 

module "s3-bucket-athena" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v5.0.0"
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy       = data.aws_iam_policy_document.athena_bucket_policy.json
  bucket_name         = "athena-cloudtrail-query"
  custom_kms_key      = aws_kms_key.s3_logging_cloudtrail.arn
  replication_enabled = false
  lifecycle_rule = [
    {
      id      = "main"
      enabled = true
      prefix  = ""
      tags    = {}
      expiration = {
        days = 7
      }
    }
  ]
  tags = local.tags
}


data "aws_iam_policy_document" "athena_bucket_policy" {
  statement {
    sid    = "AllowListBucketACL"
    effect = "Allow"
    actions = ["s3:PutObject",
      "s3:GetObject",
      "s3:GetBucketLogging",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy"

    ]
    resources = ["${module.s3-bucket-athena.bucket.arn}",
    "${module.s3-bucket-athena.bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

#IAM role for lambda access to athena
data "aws_iam_policy_document" "athena_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_athena_workgroup" "mod-platform" {
  name = "mod-platform"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.s3-bucket-athena.bucket.id}/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "aws_iam_role" "athena_lambda" {

  name = "athena_lambda"

  assume_role_policy = data.aws_iam_policy_document.athena_assume_role_policy.json

  inline_policy {
    name = "athena_lambda_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "glue:GetDatabase",
            "sts:AssumeRole",
            "glue:CreateTable",
            "glue:CreateDatabase",
            "glue:CreateSchema",
            "glue:CreatePartition",
            "athena:*",
            "glue:GetDatabases"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

#Create ZIP archive and lambda
data "archive_file" "lambda_zip" {

  depends_on = [module.s3-bucket-athena]

  type        = "zip"
  source_file = "lambda/index.py"
  output_path = "lambda/lambda_function.zip"
}

#tfsec:ignore:aws-lambda-enable-tracing

resource "aws_kms_key" "athena_logging" {
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.athena_logging.json
}

resource "aws_kms_alias" "athena_logging" {
  name          = "alias/athena-logging"
  target_key_id = aws_kms_key.athena_logging.key_id
}
data "aws_iam_policy_document" "athena_logging" {
  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "role is resticted by limited actions in member account"

  # -- AWS - Documentation reference --
  # Resource – (Required) In a key policy, the value of the Resource element is "*", 
  # which means "this KMS key." The asterisk ("*") identifies the KMS key to which the key policy is attached. 

  statement {
    sid    = "Allow management access of the key to the logging account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid    = "Allow use of the key including encryption"
    effect = "Allow"
    actions = [
      "kms:Decrypt*"
    ]
    resources = [
      "*"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_lambda_function" "athena_table_update" {

  # checkov:skip=CKV_AWS_50: "X-ray tracing is not required"
  # checkov:skip=CKV_AWS_117: "Lambda is not environment specific"
  # checkov:skip=CKV_AWS_116: "DLQ not required"
  depends_on = [
    module.s3-bucket-athena

  ]

  filename                       = "lambda/lambda_function.zip"
  function_name                  = "athena_table_update"
  role                           = aws_iam_role.athena_lambda.arn
  handler                        = "index.lambda_handler"
  source_code_hash               = data.archive_file.lambda_zip.output_path
  runtime                        = "python3.8"
  reserved_concurrent_executions = 1
  kms_key_arn                    = aws_kms_key.athena_logging.arn
  environment {
    variables = {
      mod_account = data.aws_caller_identity.mod-platform.account_id
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "run-daily"
  description         = "Runs daily at 12:15"
  schedule_expression = "cron(15 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "trigger_lamber_every_day" {
  rule      = aws_cloudwatch_event_rule.every_day.name
  target_id = "athena_table_update"
  arn       = aws_lambda_function.athena_table_update.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.athena_table_update.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_day.arn
}