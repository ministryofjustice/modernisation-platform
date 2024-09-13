module "observability_platform_tenant" {

  source = "github.com/ministryofjustice/terraform-aws-observability-platform-tenant?ref=fbbe5c8282786bcc0a00c969fe598e14f12eea9b" # v1.2.0

  observability_platform_account_id = local.environment_management.account_ids["observability-platform-production"]

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

# Grafana-Athena S3 Access Policy (Note: remove aws_iam_role reference)
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
      type        = "AWS"
      # Use a placeholder ARN for the role to avoid circular dependency
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

# Attach AmazonGrafanaAthenaAccess policy
resource "aws_iam_role_policy_attachment" "grafana_athena_attachment" {
  role       = aws_iam_role.grafana_athena.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonGrafanaAthenaAccess"
}

# S3 bucket for Grafana Athena query results
module "s3-grafana-athena-query-results" {
  source              = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=4e17731f72ef24b804207f55b182f49057e73ec9"
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
