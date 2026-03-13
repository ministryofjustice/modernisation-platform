# Delius Core
module "delius_core_ansible_aws_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-ansible-aws"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_gdpr_api_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-gdpr-api"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_gdpr_ui_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-gdpr-ui"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_ldap_automation_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-ldap-automation"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_merge_api_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-merge-api"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_merge_ui_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-merge-ui"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_openldap_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-openldap"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-production"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-training-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    local.environment_management.account_ids["delius-core-preproduction"],
    local.environment_management.account_ids["delius-core-production"],
    local.environment_management.account_ids["delius-core-training-production"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-production"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-training-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_password_reset_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-password-management"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-production"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-training-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    local.environment_management.account_ids["delius-core-preproduction"],
    local.environment_management.account_ids["delius-core-production"],
    local.environment_management.account_ids["delius-core-training-production"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-production"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-training-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_user_management_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-user-management"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_weblogic_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-weblogic"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    local.environment_management.account_ids["delius-core-preproduction"],
    local.environment_management.account_ids["delius-core-production"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_weblogic_eis_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-weblogic-eis"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    local.environment_management.account_ids["delius-core-preproduction"],
    local.environment_management.account_ids["delius-core-production"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}

module "delius_core_new_tech_pdfgenerator_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-new-tech-pdfgenerator"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    local.environment_management.account_ids["delius-core-preproduction"],
    local.environment_management.account_ids["delius-core-production"],
  ]

  tags_common = local.tags
}

module "delius_core_new_tech_web_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-new-tech-web"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    local.environment_management.account_ids["delius-core-preproduction"],
    local.environment_management.account_ids["delius-core-production"],
  ]

  tags_common = local.tags
}


module "delius_core_oracle_observer_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-oracle-observer"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    local.environment_management.account_ids["delius-core-test"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}