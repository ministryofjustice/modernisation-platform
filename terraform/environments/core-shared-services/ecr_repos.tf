# Shared Elastic container repositories
module "data_platform_update_metadata_ecr_repo" {
  source                              = "../../modules/app-ecr-repo"
  for_each                            = local.ecr_repositories
  app_name                            = each.key
  push_principals                     = each.value.push_principals
  pull_principals                     = each.value.pull_principals
  enable_retrieval_policy_for_lambdas = each.value.enable_retrieval_policy_for_lambdas
  tags_common = merge(local.tags, { "Name" = each.key }
  )
}