module "cdpt_chaps_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "cdpt-chaps"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["cdpt-chaps-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["cdpt-chaps-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["cdpt-chaps-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["cdpt-chaps-development"],
    local.environment_management.account_ids["cdpt-chaps-preproduction"],
    local.environment_management.account_ids["cdpt-chaps-production"]
  ]

  # Tags
  tags_common = local.tags
}