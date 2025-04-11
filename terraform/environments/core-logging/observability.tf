module "observability_platform_tenant" {
  source = "github.com/ministryofjustice/terraform-aws-observability-platform-tenant?ref=fbbe5c8282786bcc0a00c969fe598e14f12eea9b" # v1.2.0

  observability_platform_account_id = local.environment_management.account_ids["observability-platform-production"]

  additional_policies = {
    additional_athena_policy = aws_iam_policy.additional_athena_policy.arn
  }

  tags = local.tags
}

# Grafana-Athena Role
resource "aws_iam_role" "grafana_athena" {
  name               = "grafana-athena"
  assume_role_policy = data.aws_iam_policy_document.grafana_athena_assume_role_policy.json
}

# Assume Role Policy for Grafana-Athena
data "aws_iam_policy_document" "grafana_athena_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["athena.amazonaws.com"]
    }
  }
}

# Grafana-Athena S3 Access Policy
data "aws_iam_policy_document" "grafana_athena_policy" {
  statement {
    sid    = "s3Access"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"

    ]

    resources = [
      module.s3_moj_cur_reports_modplatform.bucket.arn,
      "${module.s3_moj_cur_reports_modplatform.bucket.arn}/*"
    ]

    principals {
      type = "AWS"
      # Use a placeholder ARN for the role to avoid circular dependency
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

# Attach AmazonGrafanaAthenaAccess policy
resource "aws_iam_role_policy_attachment" "grafana_athena_attachment" {
  role       = aws_iam_role.grafana_athena.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonGrafanaAthenaAccess"
}

# S3 bucket for CUR Reports
module "s3_moj_cur_reports_modplatform" {
  source              = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=474f27a3f9bf542a8826c76fb049cc84b5cf136f" # v8.2.1
  bucket_prefix       = "moj-cur-reports-modplatform-"
  versioning_enabled  = true
  ownership_controls  = "BucketOwnerEnforced"
  replication_enabled = false
  custom_kms_key      = aws_kms_alias.moj_cur_reports.arn
  bucket_policy       = [data.aws_iam_policy_document.moj_cur_bucket_replication_policy.json]
  providers = {
    aws.bucket-replication = aws
  }

  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"
      prefix  = ""

      tags = {
        rule      = "log"
        autoclean = "true"
      }

      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 730
      }

      noncurrent_version_transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        days = 730
      }
    }
  ]
  tags = local.tags
}

# MOJ CUR Bucket Replication Policy
data "aws_iam_policy_document" "moj_cur_bucket_replication_policy" {
  statement {
    sid    = "ReplicationPermissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${data.aws_organizations_organization.root_account.master_account_id}:role/moj-cur-reports-replication-role"
      ]
    }
    actions = [
      "s3:GetBucketVersioning",
      "s3:GetObjectVersionTagging",
      "s3:List*",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:PutBucketVersioning",
      "s3:ReplicateDelete",
      "s3:ReplicateObject",
      "s3:ReplicateTags"
    ]
    resources = [
      module.s3_moj_cur_reports_modplatform.bucket.arn,
      "${module.s3_moj_cur_reports_modplatform.bucket.arn}/*"
    ]
  }
}

# Athena Workgroup for CUR Reports
resource "aws_athena_workgroup" "mod_platform_cur_reports" {
  name = "mod-platform-cur-reports"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.s3_moj_cur_reports_modplatform.bucket.id}/workgroup/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

data "aws_iam_policy_document" "crawler_assume_permission" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "glue_service_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Additional Athena Policy
data "aws_iam_policy_document" "additional_athena_policy" {
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  #checkov:skip=CKV_AWS_111
  statement {
    sid    = "AthenaQueryAccess"
    effect = "Allow"
    actions = [
      "athena:GetDatabase",
      "athena:GetDataCatalog",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetTableMetadata",
      "athena:GetWorkGroup",
      "athena:ListDatabases",
      "athena:ListDataCatalogs",
      "athena:ListWorkGroups",
      "athena:ListTableMetadata",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "GluePermission"
    effect = "Allow"
    actions = [
      "glue:BatchGetPartition",
      "glue:CreateTable",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:ImportCatalogToGlue",
      "glue:UpdateDatabase",
      "glue:UpdateTable",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AthenaS3Access"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:PutObject"
    ]
    resources = [
      module.s3_moj_cur_reports_modplatform.bucket.arn,
      "${module.s3_moj_cur_reports_modplatform.bucket.arn}/*"
    ]
  }
  statement {
    sid     = "AthenaCURReportsAccess"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      module.s3_moj_cur_reports_modplatform.bucket.arn,
      "${module.s3_moj_cur_reports_modplatform.bucket.arn}/*"
    ]
  }

  statement {
    sid       = "S3DecryptPermission"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchPermission"
    effect = "Allow"
    actions = [
      "logs:AssociateKmsKey",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "archive_file" "cur_initializer_lambda_code" {
  type        = "zip"
  source_file = "lambda_cur/moj_cur_crawler_lambda.py"
  output_path = "lambda_cur/moj_cur_crawler_lambda.zip"
}

data "aws_iam_policy_document" "crawler_lambda_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "crawler_lambda_policy" {
  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  statement {
    sid    = "CloudWatch"
    effect = "Allow"
    actions = [
      "logs:AssociateKmsKey",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.default.arn}:*"]
  }

  statement {
    sid    = "Glue"
    effect = "Allow"
    actions = [
      "glue:StartCrawler",
    ]
    resources = ["*"]
  }
}

# Create an IAM policy from the additional Athena policy document
resource "aws_iam_policy" "additional_athena_policy" {
  name   = "additional-athena-policy"
  policy = data.aws_iam_policy_document.additional_athena_policy.json
}

resource "aws_kms_key" "moj_cur_reports" {
  description         = "KMS key used to encrypt moj-cur-reports"
  enable_key_rotation = true
  multi_region        = true
  policy              = data.aws_iam_policy_document.moj_cur_reports_kms.json
  tags                = local.tags
}

resource "aws_kms_alias" "moj_cur_reports" {
  name          = "alias/moj-cur-reports-key"
  target_key_id = aws_kms_key.moj_cur_reports.id
}

data "aws_iam_policy_document" "moj_cur_reports_kms" {
  #checkov:skip=CKV_AWS_109:"Policy is directly related to the resource"
  #checkov:skip=CKV_AWS_111:"Policy is directly related to the resource"
  #checkov:skip=CKV_AWS_356:"Policy is directly related to the resource"
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
    sid    = "Allow AWS S3, lambda & Logs service to use key"
    effect = "Allow"
    actions = [
      "kms:Decrypt*",
      "kms:Describe*",
      "kms:Encrypt*",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "Service"
      identifiers = [
        "glue.amazonaws.com",
        "lambda.amazonaws.com",
        "logs.amazonaws.com",
        "s3.amazonaws.com"
      ]
    }
  }
  statement {
    sid    = "AllowS3ReplicationSourceRoleToUseTheKey"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_organizations_organization.root_account.master_account_id}:role/moj-cur-reports-replication-role"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}

resource "aws_glue_crawler" "cost_and_usage_report_crawler" {
  name                   = "moj-cur-reports-crawler"
  database_name          = aws_glue_catalog_database.cost_and_usage_report_db.name
  role                   = aws_iam_role.crawler_role.name
  security_configuration = aws_glue_security_configuration.cost_and_usage_report_sc.name

  s3_target {
    path = "s3://${module.s3_moj_cur_reports_modplatform.bucket.id}/CUR-ATHENA/MOJ-CUR-ATHENA/MOJ-CUR-ATHENA/"
    exclusions = [
      "**.json",
      "**.yml",
      "**.sql",
      "**.csv",
      "**.gz",
      "**.zip",
    ]
  }
  schema_change_policy {
    delete_behavior = "DELETE_FROM_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}

resource "aws_glue_security_configuration" "cost_and_usage_report_sc" {
  name = "cost-and-usage-report-security-configuration"

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = "SSE-KMS"
      kms_key_arn                = aws_kms_alias.moj_cur_reports.arn
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "CSE-KMS"
      kms_key_arn                   = aws_kms_alias.moj_cur_reports.arn
    }

    s3_encryption {
      s3_encryption_mode = "SSE-KMS"
      kms_key_arn        = aws_kms_alias.moj_cur_reports.arn
    }
  }
}
resource "aws_iam_role" "crawler_role" {
  name               = "moj-cur-athena-crawler-role"
  assume_role_policy = data.aws_iam_policy_document.crawler_assume_permission.json
}

resource "aws_iam_role_policy_attachment" "glue_service_role_policy_attach" {
  policy_arn = data.aws_iam_policy.glue_service_role_policy.arn
  role       = aws_iam_role.crawler_role.name
}

resource "aws_iam_role_policy" "crawler" {
  name   = "moj-cur-athena-crawler-policy"
  role   = aws_iam_role.crawler_role.name
  policy = data.aws_iam_policy_document.additional_athena_policy.json
}

resource "aws_glue_catalog_database" "cost_and_usage_report_db" {
  name        = lower("moj-cur-athena-db")
  description = "Contains CUR data based on contents from the S3 bucket '${module.s3_moj_cur_reports_modplatform.bucket.id}'"
}

resource "aws_glue_catalog_table" "cur_report_status_table" {
  name          = "cost_and_usage_data_status"
  database_name = aws_glue_catalog_database.cost_and_usage_report_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${module.s3_moj_cur_reports_modplatform.bucket.id}/CUR-ATHENA/MOJ-CUR-ATHENA/cost_and_usage_data_status/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
    columns {
      name = "status"
      type = "string"
    }
  }
  depends_on = [aws_glue_catalog_database.cost_and_usage_report_db]
  lifecycle {
    ignore_changes = [
      parameters,
    ]
  }
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/moj_cur_crawler_lambda"
  kms_key_id        = aws_kms_alias.moj_cur_reports.arn
  retention_in_days = 365
}

resource "aws_lambda_permission" "allow_s3_bucket" {
  statement_id   = "AllowS3ToInvokeLambda"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.cur_initializer.function_name
  source_account = data.aws_caller_identity.current.account_id
  principal      = "s3.amazonaws.com"
  source_arn     = module.s3_moj_cur_reports_modplatform.bucket.arn
}

resource "aws_iam_role" "cur_initializer_lambda_executor" {
  name               = "moj-cur-athena-lambda-executor"
  assume_role_policy = data.aws_iam_policy_document.crawler_lambda_assume.json
}

resource "aws_iam_role_policy" "crawler_policy" {
  name   = "moj-cur-athena-lambda-executor-policy"
  role   = aws_iam_role.cur_initializer_lambda_executor.name
  policy = data.aws_iam_policy_document.crawler_lambda_policy.json
}

resource "aws_lambda_function" "cur_initializer" {
  # checkov:skip=CKV_AWS_50: "X-ray tracing is not required"
  # checkov:skip=CKV_AWS_117: "Lambda is not environment specific"
  # checkov:skip=CKV_AWS_116: "DLQ not required"
  # checkov:skip=CKV_AWS_272: "Code signing not required"
  function_name                  = "moj_cur_crawler_lambda"
  filename                       = "lambda_cur/moj_cur_crawler_lambda.zip"
  handler                        = "moj_cur_crawler_lambda.lambda_handler"
  runtime                        = "python3.12"
  reserved_concurrent_executions = 1
  role                           = aws_iam_role.cur_initializer_lambda_executor.arn
  timeout                        = 30
  source_code_hash               = data.archive_file.cur_initializer_lambda_code.output_base64sha256
  kms_key_arn                    = aws_kms_key.moj_cur_reports.arn
  environment {
    variables = {
      CRAWLER_NAME = aws_glue_crawler.cost_and_usage_report_crawler.name
    }
  }
  depends_on = [aws_cloudwatch_log_group.default]
}

resource "aws_s3_bucket_notification" "cur_initializer_lambda_trigger" {
  bucket = module.s3_moj_cur_reports_modplatform.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.cur_initializer.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "CUR-ATHENA/MOJ-CUR-ATHENA/"
    filter_suffix       = ".parquet"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_bucket,
  ]
}
