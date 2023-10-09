module "managed_prometheus" {
  source  = "terraform-aws-modules/managed-service-prometheus/aws"
  version = "~> 2.0"

  workspace_alias = local.application_name

  tags = local.tags
}
