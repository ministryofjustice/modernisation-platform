output "environment_nuke_accounts" {
  value     = module.environments.environment_nuke_accounts
  sensitive = true
}

output "environment_nuke_blocklist_accounts" {
  value     = module.environments.environment_nuke_blocklist_accounts
  sensitive = true
}

output "environment_rebuild_after_nuke_accounts" {
  value     = module.environments.environment_rebuild_after_nuke_accounts
  sensitive = true
}