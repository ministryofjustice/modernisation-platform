resource "local_file" "providers" {
  filename = "./providers.tf"
  content = templatefile("../templates/providers.tmpl", {
    account_regions : local.account_regions,
    assume_role : false,
    provider_key : "modernisation-platform",
    root_account_id_path : "local.root_account.master_account_id",
    tags_path : "local.global_resources"
  })
}
