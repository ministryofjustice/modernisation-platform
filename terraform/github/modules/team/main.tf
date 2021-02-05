locals {
  # GitHub usernames for the Modernisation Platform team maintainers
  # NB: Terraform shows a perputal difference in roles if someone is an organisation owner
  # and will attempt to change them from `maintainer` to `member`, so owners should go in here.
  maintainers = toset([
    "ewastempel",
    "jakemulley",
    "philhorrocks",
    "SteveMarshall"
  ])
  # GitHub usernames for the full Modernisation Platform team
  members = toset([
    "davidkelliott",
    "donmasters",
    "ewastempel",
    "jackstockley89",
    "jakemulley",
    "kcbotsh",
    "nishamoj",
    "philhorrocks",
    "seanprivett",
    "SimonPPledger",
    "SteveMarshall",
    "zuriguardiola"
  ])
  # GitHub usernames for CI users
  ci_users = toset([
    "modernisation-platform-ci"
  ])
}

resource "github_team" "default" {
  name        = var.name
  privacy     = "closed"
  description = join(" • ", [var.description, "This team is defined and managed in Terraform"])
}

# Team memberships (as "maintainers")
resource "github_team_membership" "maintainers" {
  for_each = local.maintainers
  team_id  = github_team.default.id
  username = each.value
  role     = "maintainer"
}

# CI users need to be a maintainer to edit team memberships through Terraform
resource "github_team_membership" "ci" {
  for_each = local.ci_users
  team_id  = github_team.default.id
  username = each.value
  role     = "maintainer"
}

# Team memberships (as "members")
resource "github_team_membership" "members" {
  for_each = toset([
    for user in local.members :
    user
    if !contains(local.maintainers, user)
  ])
  team_id  = github_team.default.id
  username = each.value
  role     = "member"
}

# Repositories to give access to
resource "github_team_repository" "default" {
  for_each   = var.repositories
  team_id    = github_team.default.id
  repository = each.value
  permission = "admin"
}
