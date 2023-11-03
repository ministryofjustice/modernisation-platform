module "managed_grafana" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
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

  iam_role_policy_arns = [module.amazon_managed_prometheus_remote_cloudwatch_iam_policy.arn]

  role_associations = {
    "ADMIN" = {
      "group_ids" = ["16a2d234-1031-70b5-2657-7f744c55e48f", "7652b2d4-d0d1-707f-66ae-0b176587547e"] # observability-platform
    }
  }

  tags = local.tags
}
