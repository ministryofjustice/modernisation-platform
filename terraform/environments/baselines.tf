resource "local_file" "providers" {
  for_each = module.environments.environment_account_ids
  filename = "./providers-${each.key}.tf"
  content = templatefile("../templates/providers.tmpl", {
    account_regions : local.account_regions,
    assume_role : true,
    provider_key : each.key,
    root_account_id_path : "local.root_account.master_account_id",
    tags_path : "local.environments"
  })
}
