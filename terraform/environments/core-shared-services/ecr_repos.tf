# Shared Elastic container repositories
module "maat_api_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "maat-cd-api"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["maat-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["maat-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["maat-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["maat-development"],
    local.environment_management.account_ids["maat-test"],
    local.environment_management.account_ids["maat-preproduction"],
    local.environment_management.account_ids["maat-production"]
  ]

  # Tags
  tags_common = local.tags
}

module "maat_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "maat"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["maat-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["maat-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["maat-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["maat-development"],
    local.environment_management.account_ids["maat-test"],
    local.environment_management.account_ids["maat-preproduction"],
    local.environment_management.account_ids["maat-production"]
  ]

  # Tags
  tags_common = local.tags
}

module "performance_hub_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "performance-hub"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["performance-hub-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["performance-hub-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["performance-hub-production"]}:role/modernisation-platform-oidc-cicd"
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
    "arn:aws:iam::${local.environment_management.account_ids["mlra-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["mlra-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["mlra-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["mlra-development"],
    local.environment_management.account_ids["mlra-test"],
    local.environment_management.account_ids["mlra-preproduction"],
    local.environment_management.account_ids["mlra-production"],
    local.environment_management.account_ids["apex-development"]
  ]

  # Tags
  tags_common = local.tags
}

# ECR repo holding the APEX application container image
module "apex_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "apex"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["apex-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["apex-development"]
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["apex-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["apex-development"],
    local.environment_management.account_ids["apex-test"],
    local.environment_management.account_ids["apex-preproduction"],
    local.environment_management.account_ids["apex-production"]
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
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-production"]}:role/modernisation-platform-oidc-cicd",
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

module "data_platform_athena_load_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-athena-load-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_athena_load*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_athena_load*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_athena_load*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_athena_load*"
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_get_glue_metadata_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-get-glue-metadata-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_get_glue_metadata*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_get_glue_metadata*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_get_glue_metadata*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_get_glue_metadata*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_presigned_url_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-presigned-url-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
    local.environment_management.account_ids["analytical-platform-data-engineering-sandboxa"]
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_presigned_url*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_presigned_url*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_presigned_url*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_presigned_url*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-data-engineering-sandboxa"]}:function:data_product_presigned_url*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_authorizer_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-authorizer-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
    local.environment_management.account_ids["analytical-platform-data-engineering-sandboxa"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_authorizer*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_authorizer*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_authorizer*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_authorizer*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-data-engineering-sandboxa"]}:function:data_product_authorizer*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_docs_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-docs-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_docs*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_docs*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_docs*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_docs*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_python_base_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-python-base"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_create_metadata_lambda_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-create-metadata-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_create_metadata*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_create_metadata*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_create_metadata*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_create_metadata*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_resync_unprocessed_files_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-resync-unprocessed-files-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:resync_unprocessed_files*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:resync_unprocessed_files*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:resync_unprocessed_files*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:resync_unprocessed_files*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_reload_data_product_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-reload-data-product-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:reload_data_product*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:reload_data_product*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:reload_data_product*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:reload_data_product*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_landing_to_raw_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-landing-to-raw-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_landing_to_raw*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_landing_to_raw*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_landing_to_raw*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_landing_to_raw*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_get_schema_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-get-schema-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:get_schema*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:get_schema*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:get_schema*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:get_schema*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_create_schema_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-create-schema-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_create_schema*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_create_schema*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_create_schema*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_create_schema*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_update_metadata_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-update-metadata-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_update_metadata*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_update_metadata*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_update_metadata*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_update_metadata*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_update_schema_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-update-schema-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_update_schema*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_update_schema*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_update_schema*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_update_schema*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_query_data_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-preview-data-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_preview_data*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_preview_data*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_preview_data*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_preview_data*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_delete_table_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-delete-table-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:delete_table_for_data_product_*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:delete_table_for_data_product_*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:delete_table_for_data_product_*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:delete_table_for_data_product_*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_push_to_catalogue_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-push-to-catalogue-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_push_to_catalogue*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_push_to_catalogue*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_push_to_catalogue*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_push_to_catalogue*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_delete_data_product_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-delete-data-product-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["data-platform-development"],
    local.environment_management.account_ids["data-platform-test"],
    local.environment_management.account_ids["data-platform-preproduction"],
    local.environment_management.account_ids["data-platform-production"],
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:delete_data_product*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:delete_data_product*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:delete_data_product*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:delete_data_product*",
  ]

  # Tags
  tags_common = local.tags
}

module "data_platform_jml_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "data-platform-jml-extract-lambda"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-data-production"]}:function:data_platform_jml_extract*"
  ]

  # Tags
  tags_common = local.tags
}

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

module "delius_core_password_reset_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "delius-core-password-management"

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


module "analytical_platform_ingestion_notify_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "analytical-platform-ingestion-notify"

  push_principals = ["arn:aws:iam::${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:role/modernisation-platform-oidc-cicd"]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["analytical-platform-ingestion-development"],
    local.environment_management.account_ids["analytical-platform-ingestion-production"]
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:function:notify-quarantined*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-ingestion-production"]}:function:notify-quarantined*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:function:notify-transferred*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-ingestion-production"]}:function:notify-transferred*"
  ]

  # Tags
  tags_common = local.tags
}

module "analytical_platform_ingestion_scan_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "analytical-platform-ingestion-scan"

  push_principals = ["arn:aws:iam::${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:role/modernisation-platform-oidc-cicd"]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["analytical-platform-ingestion-development"],
    local.environment_management.account_ids["analytical-platform-ingestion-production"],
    # Electronic monitoring data store accounts.
    local.environment_management.account_ids["electronic-monitoring-data-development"],
    local.environment_management.account_ids["electronic-monitoring-data-preproduction"],
    local.environment_management.account_ids["electronic-monitoring-data-production"],
    local.environment_management.account_ids["electronic-monitoring-data-test"]
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:function:scan*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-ingestion-production"]}:function:scan*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:function:definition-upload*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-ingestion-production"]}:function:definition-upload*",
    # Electronic monitoring data store accounts.
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-development"]}:function:scan*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-preproduction"]}:function:scan*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-production"]}:function:scan*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-test"]}:function:scan*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-development"]}:function:definition-upload*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-preproduction"]}:function:definition-upload*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-production"]}:function:definition-upload*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-test"]}:function:definition-upload*",
  ]

  # Tags
  tags_common = local.tags
}

module "analytical_platform_ingestion_transfer_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "analytical-platform-ingestion-transfer"

  push_principals = ["arn:aws:iam::${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:role/modernisation-platform-oidc-cicd"]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["analytical-platform-ingestion-development"],
    local.environment_management.account_ids["analytical-platform-ingestion-production"]
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-ingestion-development"]}:function:transfer*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-ingestion-production"]}:function:transfer*"
  ]

  # Tags
  tags_common = local.tags
}

module "observability_platform_grafana_api_key_rotator_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "observability-platform-grafana-api-key-rotator"

  push_principals = ["arn:aws:iam::${local.environment_management.account_ids["observability-platform-development"]}:role/modernisation-platform-oidc-cicd"]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["observability-platform-development"]}:role/modernisation-platform-oidc-cicd",
    local.environment_management.account_ids["observability-platform-development"],
    local.environment_management.account_ids["observability-platform-production"]
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["observability-platform-development"]}:function:grafana-api-key-rotator*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["observability-platform-production"]}:function:grafana-api-key-rotator*"
  ]

  tags_common = local.tags
}

# Repo for electronic monitoring data account lambda
module "electronic_monitoring_data_lambdas_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "electronic-monitoring-data-lambdas"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["electronic-monitoring-data-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["electronic-monitoring-data-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["electronic-monitoring-data-production"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["electronic-monitoring-data-test"]}:role/modernisation-platform-oidc-cicd",
  ]

  pull_principals = [
    local.environment_management.account_ids["electronic-monitoring-data-development"],
    local.environment_management.account_ids["electronic-monitoring-data-preproduction"],
    local.environment_management.account_ids["electronic-monitoring-data-production"],
    local.environment_management.account_ids["electronic-monitoring-data-test"]

  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-development"]}:function:*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-preproduction"]}:function:*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-production"]}:function:*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-test"]}:function:*",
  ]

  # Tags
  tags_common = local.tags
}


# Repo for generic data load and build tool image
module "create_a_data_task_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "create-a-data-task"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["electronic-monitoring-data-development"]}:role/modernisation-platform-oidc-cicd",
  ]

  pull_principals = [
    local.environment_management.account_ids["electronic-monitoring-data-development"],
    local.environment_management.account_ids["analytical-platform-data-engineering-sandboxa"],
    local.environment_management.account_ids["electronic-monitoring-data-production"]
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-development"]}:function:*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-production"]}:function:*"
  ]

  # Tags
  tags_common = local.tags
}

# ECR repo holding the yjaf app images
module "yjaf_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "youth-justice-app-framework"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["youth-justice-app-framework-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["youth-justice-app-framework-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["youth-justice-app-framework-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["youth-justice-app-framework-production"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["youth-justice-app-framework-development"]}:role/circleci_iam_role",
    "arn:aws:iam::${local.environment_management.account_ids["youth-justice-app-framework-test"]}:role/circleci_iam_role",
  ]

  pull_principals = [
    local.environment_management.account_ids["youth-justice-app-framework-development"],
    local.environment_management.account_ids["youth-justice-app-framework-test"],
    local.environment_management.account_ids["youth-justice-app-framework-preproduction"],
    local.environment_management.account_ids["youth-justice-app-framework-production"]
  ]

  # Tags
  tags_common = local.tags
}

module "observability_platform_grafana_sigv4_proxy_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "observability-platform-grafana-sigv4-proxy"

  push_principals = [
    local.environment_management.account_ids["core-shared-services-production"]
  ]

  pull_principals = [
    local.environment_management.account_ids["observability-platform-development"],
    local.environment_management.account_ids["observability-platform-production"]
  ]

  enable_retrieval_policy_for_lambdas = [
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["observability-platform-development"]}:function:sigv4-proxy*",
    "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["observability-platform-production"]}:function:sigv4-proxy*"
  ]

  tags_common = local.tags
}

module "soa_admin_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "soa-admin"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["laa-ccms-soa-development"]}:root"
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["laa-ccms-soa-development"]}:root",
    "arn:aws:iam::${local.environment_management.account_ids["laa-ccms-soa-test"]}:root",
    "arn:aws:iam::${local.environment_management.account_ids["laa-ccms-soa-preproduction"]}:root",
    "arn:aws:iam::${local.environment_management.account_ids["laa-ccms-soa-production"]}:root"
  ]
  tags_common = local.tags
}

module "soa_managed_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "soa-managed"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["laa-ccms-soa-development"]}:root"
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["laa-ccms-soa-development"]}:root",
    "arn:aws:iam::${local.environment_management.account_ids["laa-ccms-soa-test"]}:root",
    "arn:aws:iam::${local.environment_management.account_ids["laa-ccms-soa-preproduction"]}:root",
    "arn:aws:iam::${local.environment_management.account_ids["laa-ccms-soa-production"]}:root"
  ]
  tags_common = local.tags
}

module "edrms_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "ccms-edrms"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["ccms-edrms-development"]}:root"
  ]

  pull_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["ccms-edrms-development"]}:root",
    "arn:aws:iam::${local.environment_management.account_ids["ccms-edrms-test"]}:root",
    "arn:aws:iam::${local.environment_management.account_ids["ccms-edrms-preproduction"]}:root",
    "arn:aws:iam::${local.environment_management.account_ids["ccms-edrms-production"]}:root"
  ]
  tags_common = local.tags
}

module "vcms_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "vcms"

  push_principals = [
    "arn:aws:iam::${local.environment_management.account_ids["vcms-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["vcms-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["vcms-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["vcms-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  pull_principals = [
    local.environment_management.account_ids["vcms-development"],
    local.environment_management.account_ids["vcms-test"],
    local.environment_management.account_ids["vcms-preproduction"],
    local.environment_management.account_ids["vcms-production"],
    "arn:aws:iam::${local.environment_management.account_ids["vcms-development"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["vcms-test"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["vcms-preproduction"]}:role/modernisation-platform-oidc-cicd",
    "arn:aws:iam::${local.environment_management.account_ids["vcms-production"]}:role/modernisation-platform-oidc-cicd"
  ]

  # Tags
  tags_common = local.tags
}
