resource "github_team" "default" {
  name                      = var.name
  privacy                   = "closed"
  description               = join(" • ", [var.description, "This team is defined and managed in Terraform"])
  parent_team_id            = var.parent_team_id
  create_default_maintainer = true
}

# Team memberships (as "maintainers")
resource "github_team_membership" "maintainers" {
  for_each = var.maintainers
  team_id  = github_team.default.id
  username = each.value
  role     = "maintainer"
}

# CI users need to be a maintainer to edit team memberships through Terraform
resource "github_team_membership" "ci" {
  for_each = var.ci
  team_id  = github_team.default.id
  username = each.value
  role     = "maintainer"
}

# Team memberships (as "members")
resource "github_team_membership" "members" {
  for_each = toset([
    for user in var.members :
    user
    if ! contains(var.maintainers, user)
  ])
  team_id  = github_team.default.id
  username = each.value
  role     = "member"

  depends_on = [github_team_membership.ci]
}

# Repositories to give access to
resource "github_team_repository" "default" {
  for_each   = var.repositories
  team_id    = github_team.default.id
  repository = each.value
  permission = "admin"
}
