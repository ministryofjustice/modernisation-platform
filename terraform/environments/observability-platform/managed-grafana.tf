module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 2.0"

  name = local.application_name

  # license_type = "ENTERPRISE_FREE_TRIAL"
  associate_license = false

  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["CLOUDWATCH", "PROMETHEUS"]
  notification_destinations = ["SNS"]

  role_associations = {
    "ADMIN" = {
      "group_ids" = ["16a2d234-1031-70b5-2657-7f744c55e48f"] # observability-platform
    }
  }

  tags = local.tags
}
