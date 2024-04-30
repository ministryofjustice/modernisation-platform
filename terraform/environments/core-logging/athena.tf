data "aws_caller_identity" "mod-platform" {
  provider = aws.modernisation-platform
}

data "aws_kms_alias" "environment_management" {
  provider = aws.modernisation-platform
  name     = "alias/environment-management"
}

#S3 Bucket for Athena temp SQL queries 

module "s3-bucket-athena" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=8688bc15a08fbf5a4f4eef9b7433c5a417df8df1" # v7.0.0
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy       = [data.aws_iam_policy_document.athena_bucket_policy.json]
  bucket_name         = "athena-cloudtrail-query"
  custom_kms_key      = aws_kms_key.s3_logging_cloudtrail.arn
  replication_enabled = false
  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"
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
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetBucketLogging",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy"
    ]
    resources = [module.s3-bucket-athena.bucket.arn,
    format("%s/*", module.s3-bucket-athena.bucket.arn)]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
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
            "glue:GetTable",
            "glue:GetTables",
            "glue:CreateTable",
            "glue:CreateDatabase",
            "glue:CreateSchema",
            "glue:CreatePartition",
            "glue:GetDatabases",
            "glue:GetPartitions",
            "glue:DeleteTable"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "athena:StartQueryExecution",
          ]
          Effect = "Allow"
          Resource = [
            aws_athena_workgroup.mod-platform.arn,
            format("arn:aws:athena:eu-west-2:%s:workgroup/primary", data.aws_caller_identity.current.account_id)
          ]
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.modernisation-platform.account_id}:secret:environment_management*"
        },
        {
          Action = [
            "ssm:GetParameter"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/environment_management_arn"
        },
        {
          Action = [
            "kms:Decrypt*",
            "kms:GenerateDataKey"
          ]
          Effect = "Allow"
          Resource = [
            aws_kms_key.s3_logging_cloudtrail.arn,
            aws_kms_key.athena_logging.arn,
            data.aws_kms_alias.environment_management.target_key_arn
          ]
        },
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/environment_management_arn"
        },
        {
          Action = [
            "s3:*Object",
            "s3:GetBucketLocation",
            "s3:List*"
          ]
          Effect = "Allow"
          Resource = [
            "${module.s3-bucket-athena.bucket.arn}/*",
            module.s3-bucket-athena.bucket.arn
          ]
        },
        {
          Action = [
            "s3:GetBucketLocation",
            "s3:List*",
            "s3:Get*"
          ]
          Effect = "Allow"
          Resource = [
            module.s3-bucket-cloudtrail-logging.bucket.arn,
            "${module.s3-bucket-cloudtrail-logging.bucket.arn}/*"
          ]
        }
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
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
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

# tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "athena_table_update" {
  # checkov:skip=CKV_AWS_50: "X-ray tracing is not required"
  # checkov:skip=CKV_AWS_117: "Lambda is not environment specific"
  # checkov:skip=CKV_AWS_116: "DLQ not required"
  # checkov:skip=CKV_AWS_272: "Code signing not required"
  depends_on = [
    module.s3-bucket-athena

  ]

  filename                       = "lambda/lambda_function.zip"
  function_name                  = "athena_table_update"
  role                           = aws_iam_role.athena_lambda.arn
  handler                        = "index.lambda_handler"
  source_code_hash               = data.archive_file.lambda_zip.output_base64sha256
  runtime                        = "python3.12"
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