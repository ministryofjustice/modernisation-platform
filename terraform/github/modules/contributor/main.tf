resource "github_team_repository" "main" {
  for_each   = { for team in var.application_teams : team => team if contains(local.all_team_slugs, team)}
  team_id    = each.value
  repository = var.repository_id
  permission = "push"
}