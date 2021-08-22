# Everyone, with access to the above repositories
module "core-team" {
  source      = "./modules/team"
  name        = "modernisation-platform"
  description = "Modernisation Platform team"
  repositories = [
    module.core.repository.id,
    module.hello-world.repository.id,
    module.terraform-module-baselines.repository.id,
    module.terraform-module-cross-account-access.repository.id,
    module.terraform-module-environments.repository.id,
    module.terraform-module-iam-superadmins.repository.id,
    module.terraform-module-s3-bucket-replication-role.repository.id,
    module.terraform-module-s3-bucket.repository.id,
    module.terraform-module-trusted-advisor.repository.id,
    module.terraform-module-bastion-linux.repository.id,
    module.modernisation-platform-environments.repository.id
  ]

  maintainers = local.maintainers
  members     = local.everyone
  ci          = local.ci_users
}

# People who need full AWS access
module "aws-team" {
  source      = "./modules/team"
  name        = "modernisation-platform-engineers"
  description = "Modernisation Platform team: people who require AWS access"

  maintainers = local.maintainers
  members     = local.engineers
  ci          = local.ci_users

  parent_team_id = module.core-team.team_id
}

# Give write access to teams on the environments repo (access to merge to main is restricted by codeowners file)
resource "github_team_repository" "modernisation-platform-environments-access" {
  for_each   = { for team in local.application_teams : team => team }
  team_id    = each.value
  repository = module.modernisation-platform-environments.repository.id
  permission = "push"
}
