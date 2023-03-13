# Shared Elastic container repositories
module "performance_hub_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "performance-hub"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["performance-hub-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["performance-hub-preproduction"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["performance-hub-production"]}:user/cicd-member-user"
  ]

  pull_principals = [
    local.environment_management.account_ids["performance-hub-development"],
    local.environment_management.account_ids["performance-hub-preproduction"],
    local.environment_management.account_ids["performance-hub-production"]
  ]

  # Tags
  tags_common = local.tags
}

module "mlra_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "mlra"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["mlra-development"]}:user/cicd-member-user",
    local.environment_management.account_ids["mlra-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["mlra-development"]}:user/cicd-member-user",
    local.environment_management.account_ids["mlra-development"],
    local.environment_management.account_ids["apex-development"]
  ]

  # Tags
  tags_common = local.tags
}

module "instance_scheduler_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "instance-scheduler"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:role/github-actions"
  ]

  pull_principals = [
    local.environment_management.account_ids["core-shared-services-production"],
    local.environment_management.account_ids["testing-test"] # to enable terratest runs
  ]

  enable_retrieval_policy_for_lambdas = ["arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["core-shared-services-production"]}:function:*", "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["testing-test"]}:function:*"]

  # Tags
  tags_common = local.tags
}

module "delius_jitbit_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-jitbit"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-preproduction"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-production"]}:user/cicd-member-user"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-jitbit-development"],
    local.environment_management.account_ids["delius-jitbit-preproduction"],
    local.environment_management.account_ids["delius-jitbit-production"]
  ]

  # Tags
  tags_common = local.tags
}
