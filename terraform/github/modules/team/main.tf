resource "github_team" "default" {
  name        = var.name
  privacy     = "closed"
  description = join(" — ", [var.description, "This team is defined and managed in Terraform."])
}

resource "github_team_membership" "default" {
  team_id  = github_team.default.id
  username = "jakemulley"
  role     = "maintainer"
}

# Repositories to give access to
resource "github_team_repository" "default" {
  for_each   = var.repositories
  team_id    = github_team.default.id
  repository = each.value
  permission = "admin"
}
