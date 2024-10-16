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
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      module.s3-grafana-athena-query-results.bucket.arn,
      "${module.s3-grafana-athena-query-results.bucket.arn}/*"
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

# S3 bucket for Grafana Athena query results
module "s3-grafana-athena-query-results" {
  source              = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=4e17731f72ef24b804207f55b182f49057e73ec9" # v8.1.0
  bucket_prefix       = "grafana-athena-query-results-"
  versioning_enabled  = true
  ownership_controls  = "BucketOwnerEnforced"
  replication_enabled = false
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

# S3 bucket for CUR Reports
module "s3-moj-cur-reports-modplatform" {
  source              = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=4e17731f72ef24b804207f55b182f49057e73ec9" # v8.1.0
  bucket_prefix       = "moj-cur-reports-modplatform-"
  versioning_enabled  = true
  ownership_controls  = "BucketOwnerEnforced"
  replication_enabled = false
  custom_kms_key      = aws_kms_key.moj-cur-reports.arn
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
      module.s3-moj-cur-reports-modplatform.bucket.arn,
      "${module.s3-moj-cur-reports-modplatform.bucket.arn}/*"
    ]
  }
}

# Athena Workgroup for CUR Reports
resource "aws_athena_workgroup" "mod-platform-cur-reports" {
  name = "mod-platform-cur-reports"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.s3-grafana-athena-query-results.bucket.id}/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

# Additional Athena Policy
data "aws_iam_policy_document" "additional_athena_policy" {
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  #checkov:skip=CKV_AWS_111
  statement {
    sid    = "AthenaQueryAccess"
    effect = "Allow"
    actions = [
      "athena:ListDatabases",
      "athena:ListDataCatalogs",
      "athena:ListWorkGroups",
      "athena:GetDatabase",
      "athena:GetDataCatalog",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetTableMetadata",
      "athena:GetWorkGroup",
      "athena:ListTableMetadata",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "GlueReadAccess"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AthenaS3Access"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::grafana-athena-query-results-*"]
  }
  statement {
    sid       = "AthenaCURReportsAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::moj-cur-reports-modplatform*"]
  }
}

# Create an IAM policy from the additional Athena policy document
resource "aws_iam_policy" "additional_athena_policy" {
  name   = "additional-athena-policy"
  policy = data.aws_iam_policy_document.additional_athena_policy.json
}

resource "aws_kms_key" "moj-cur-reports" {
  description         = "KMS key used to encrypt moj-cur-reports"
  enable_key_rotation = true
  multi_region        = true
  policy              = data.aws_iam_policy_document.moj-cur-reports_kms.json
  tags                = local.tags
}

resource "aws_kms_alias" "moj-cur-reports" {
  name          = "alias/moj-cur-reports-key"
  target_key_id = aws_kms_key.moj-cur-reports.id
}

data "aws_iam_policy_document" "moj-cur-reports_kms" {
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
    sid    = "Allow AWS S3 service to use key"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "Service"
      identifiers = [
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
      "kms:GenerateDataKey",
      "kms:Encrypt"
    ]
    resources = ["*"]
  }
}
