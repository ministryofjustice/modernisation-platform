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

            "arn:aws:secretsmanager:eu-west-2:946070829339:secret:environment_management-BLRCDb",
            "arn:aws:secretsmanager:eu-west-2:946070829339:secret:environment_management"
          ]
        },
      ]
    })
  }
}

#S3 Bucket for Athena temp SQL queries 
resource "aws_s3_bucket" "athena_query" {
  bucket = "athena-cloudtrail-query"
  acl    = "private"

  tags = {
    Name        = "athena-cloudtrail-query"
    Environment = "Production"
  }
}

resource "aws_athena_workgroup" "mod-platform" {
  name = "mod-platform"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_query.bucket}/"

    }
  }
}

resource "aws_s3_bucket_policy" "athena_query_policy" {
  bucket = aws_s3_bucket.athena_query.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "athenas3querypolicy"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "AWS" : "*"
        },
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.athena_query.arn,
          "${aws_s3_bucket.athena_query.arn}/*",
        ]

      },
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "s3_block_public_access" {

  depends_on = [
    aws_s3_bucket_policy.athena_query_policy
  ]

  bucket = aws_s3_bucket.athena_query.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
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
          "glue:GetDatabases"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

#Create ZIP archive and lambda
data "archive_file" "lambda_zip" {

  depends_on = [module.s3-bucket-cloudtrail]

  type        = "zip"
  source_file = "lambda/index.py"
  output_path = "lambda/lambda_function.zip"
}

resource "aws_lambda_function" "athena_table_update" {

  depends_on = [
    aws_s3_bucket.athena_query,

  ]

  filename         = "lambda/lambda_function.zip"
  function_name    = "athena_table_update"
  role             = aws_iam_role.athena_lambda.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_path
  runtime          = "python3.7"
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