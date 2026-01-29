module "cdpt_ifs_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "cdpt-ifs"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["cdpt-ifs-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["cdpt-ifs-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["cdpt-ifs-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["cdpt-ifs-development"],
    local.environment_management.account_ids["cdpt-ifs-preproduction"],
    local.environment_management.account_ids["cdpt-ifs-production"]
  ]

  # Tags
  tags_common = local.tags
}
