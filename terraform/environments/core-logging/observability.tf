module "observability_platform_tenant" {

  source = "github.com/ministryofjustice/terraform-aws-observability-platform-tenant?ref=fbbe5c8282786bcc0a00c969fe598e14f12eea9b" # v1.2.0

  observability_platform_account_id = local.environment_management.account_ids["observability-platform-production"]

  tags = local.tags
}

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

  tags = merge(local.tags,
   { Name = lower(format("s3-bucket-%s-%s-grafana-athena", local.application_name, local.environment))  }
  )
}
