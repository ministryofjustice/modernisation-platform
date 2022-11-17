resource "github_team_repository" "modernisation-platform-ami-builds-access" {
  for_each   = { for team in var.application_teams : team => team }
  team_id    = each.value
  repository = var.repository_id
  permission = "push"
}