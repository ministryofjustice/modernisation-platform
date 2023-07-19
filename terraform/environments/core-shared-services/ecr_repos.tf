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
    local.environment_management.account_ids["mlra-test"],
    local.environment_management.account_ids["mlra-preproduction"],
    local.environment_management.account_ids["mlra-production"],
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

# ECR repo holding the hmpps jitbit application container image
module "delius_jitbit_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-jitbit"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-test"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-preproduction"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-production"]}:user/cicd-member-user"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-jitbit-development"],
    local.environment_management.account_ids["delius-jitbit-test"],
    local.environment_management.account_ids["delius-jitbit-preproduction"],
    local.environment_management.account_ids["delius-jitbit-production"]
  ]

  # Tags
  tags_common = local.tags
}

# ECR repo holding the hmpps delius core weblogic container image
module "delius_core_weblogic_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-weblogic"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
  ]

  # Tags
  tags_common = local.tags
}

# ECR repo holding the hmpps delius core database container image used for testing purposes
module "delius_core_testing_db_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-testing-db"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
  ]

  # Tags
  tags_common = local.tags
}

# ECR repo holding the hmpps delius core openldap container image
module "delius_core_openldap_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-openldap"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_code_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-code-extractor"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/data-platform-gha",
    local.environment_management.account_ids["data-platform-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    local.environment_management.account_ids["data-platform-development"],
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_data_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-data-extractor"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/data-platform-gha",
    local.environment_management.account_ids["data-platform-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    local.environment_management.account_ids["data-platform-development"],
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_athena_load_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-athena-load-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/data-platform-gha",
    local.environment_management.account_ids["data-platform-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    local.environment_management.account_ids["data-platform-development"],
  ]

  enable_retrieval_policy_for_lambdas = ["arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_athena_load*"]

  # Tags
  tags_common = local.tags
}

module "data_platform_get_glue_metadata_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-get-glue-metadata-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/data-platform-gha",
    local.environment_management.account_ids["data-platform-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    local.environment_management.account_ids["data-platform-development"],
  ]

  enable_retrieval_policy_for_lambdas = ["arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_get_glue_metadata*"]

  # Tags
  tags_common = local.tags
}

module "data_platform_presigned_url_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-presigned-url-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/data-platform-gha",
    local.environment_management.account_ids["data-platform-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    local.environment_management.account_ids["data-platform-development"],
  ]

  enable_retrieval_policy_for_lambdas = ["arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_presigned_url*"]

  # Tags
  tags_common = local.tags
}

module "data_platform_authorizer_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-authorizer-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/data-platform-gha",
    local.environment_management.account_ids["data-platform-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    local.environment_management.account_ids["data-platform-development"],
  ]

  enable_retrieval_policy_for_lambdas = ["arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_authorizer*"]

  # Tags
  tags_common = local.tags
}

module "data_platform_docs_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-docs-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/data-platform-gha",
    local.environment_management.account_ids["data-platform-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
    local.environment_management.account_ids["data-platform-development"],
  ]

  enable_retrieval_policy_for_lambdas = ["arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_docs*"]

  # Tags
  tags_common = local.tags
}

# ECR repo holding the hmpps delius core ansible aws automation container image
module "delius_core_ansible_aws_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-ansible-aws"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
  ]

  pull_principals = [
    local.environment_management.account_ids["delius-core-development"],
    "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
  ]

  # Tags
  tags_common = local.tags
}
