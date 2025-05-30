# Because we manage team memberships and repositories through separate modules we use a standalone resource
# to avoid any issues with circular dependencies
resource "github_repository_collaborators" "this" {
  for_each   = local.map_permissions_to_repositories
  repository = each.key
  dynamic "ignore_team" {
    for_each = toset([
      "4380209",  # organisation-security-auditor
      "13130047", # organisation-security-auditor-external
      "13149335"  # organisation-security-auditor-architects
    ])
    content {
      team_id = ignore_team.value
    }
  }
  dynamic "team" {
    for_each = each.value.teams
    content {
      team_id    = team.key
      permission = team.value
    }
  }
  dynamic "user" {
    for_each = each.value.users
    content {
      username   = user.key
      permission = user.value
    }
  }
}
