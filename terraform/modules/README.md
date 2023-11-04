# Modernisation Platform modules

This directory contains modules that the Modernisation Platform team have written for internal testing before wider use. Once a module is mature enough, it will be moved to its own repository, like [modernisation-platform-terraform-baselines](https://github.com/ministryofjustice/modernisation-platform-terraform-baselines).

# Details about Refactor app-ecr-repo module
I have refactored the code to use a single module call, supplying it with a map of values through a for_each expression. This was done non-destructively and has significantly reduced the quantity of code in the file.

Here, all the values are contained within a map and moved to locals. Values are supplied from this map to the single module making all the calls using for_each.

'''
module "data_platform_update_metadata_ecr_repo" {
  source = "../../modules/app-ecr-repo"
  for_each = local.ecr_repositories
  app_name = each.key
  push_principals = each.value.push_principals
  pull_principals = each.value.pull_principals
  enable_retrieval_policy_for_lambdas = each.value.permitted_lambdas
  tags_common = merge(
    local.tags,
    { "Name" = each.key }
  )
}
'''