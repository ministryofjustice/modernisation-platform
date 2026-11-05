# Grafana Private Data Source Connect (PDC) agent, mirrored from grafana/pdc-agent on Docker Hub
module "observability_platform_pdc_agent_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "observability-platform-pdc-agent"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["observability-platform-development"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["observability-platform-development"],
    local.environment_management.account_ids["observability-platform-production"]
  ]

  tags_common = local.tags
}
