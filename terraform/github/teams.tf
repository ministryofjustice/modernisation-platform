# Everyone, with access to the above repositories
module "core-team" {
  source      = "./modules/team"
  name        = "modernisation-platform"
  description = "Modernisation Platform team"
  maintainers = local.maintainers
  members     = local.everyone
  ci          = local.ci_users
}

# People who need full AWS access
module "aws-team" {
  source         = "./modules/team"
  name           = "modernisation-platform-engineers"
  description    = "Modernisation Platform team: people who require AWS access"
  maintainers    = local.maintainers
  members        = local.engineers
  ci             = local.ci_users
  parent_team_id = module.core-team.team_id
}

module "security-team" {
  source      = "./modules/team"
  name        = "modernisation-platform-security"
  description = "Modernisation Platform security review team"
  maintainers = local.maintainers
  members     = local.security
}

module "long-term-storage" {
  source      = "./modules/team"
  name        = "modernisation-platform-long-term-storage"
  description = "Modernisation Platform long term storage team"
  maintainers = local.maintainers
  members     = local.long-term-storage
}
