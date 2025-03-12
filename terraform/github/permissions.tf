# Because we manage team memberships and repositories through separate modules we use a standalone resource
# to avoid any issues with circular dependencies
resource "github_repository_collaborators" "this" {
  for_each   = local.map_permissions_to_repositories
  repository = each.key
  ignore_team {
    team_id = "4380209" #organisation-security-auditor
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
