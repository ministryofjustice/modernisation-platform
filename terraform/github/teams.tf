# Everyone, with access to the above repositories
module "core-team" {
  source      = "./modules/team"
  name        = "modernisation-platform"
  description = "Modernisation Platform team"
  repositories = [
    module.core.repository.name,
    module.terraform-module-baselines.repository.name,
    module.terraform-module-cross-account-access.repository.name,
    module.terraform-module-environments.repository.name,
    module.terraform-module-iam-superadmins.repository.name,
    module.terraform-module-s3-bucket-replication-role.repository.name,
    module.terraform-module-s3-bucket.repository.name,
    module.terraform-module-bastion-linux.repository.name,
    module.terraform-module-aws-vm-import.repository.name,
    module.modernisation-platform-instance-scheduler.repository.name,
    module.terraform-module-aws-loadbalancer.repository.name,
    module.modernisation-platform-ami-builds.repository.name,
    module.modernisation-platform-environments.repository.name,
    module.modernisation-platform-terraform-member-vpc.repository.name,
    module.modernisation-platform-cp-network-test.repository.name,
    module.modernisation-platform-terraform-module-template.repository.name,
    module.modernisation-platform-terraform-pagerduty-integration.repository.name,
    module.terraform-module-github-oidc-provider.repository.name,
    module.terraform-module-github-oidc-role.repository.name,
    module.modernisation-platform-configuration-management.repository.name,
    module.terraform-module-lambda-function.repository.name,
    module.terraform-module-ssm-patching.repository.name,
    module.terraform-module-ec2-instance.repository.name,
    module.terraform-module-ec2-autoscaling-group.repository.name,
    module.terraform-module-ecs-cluster.repository.name,
    module.modernisation-platform-terraform-dns-certificates.repository.name
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

# Allow github users to contribute to our repos
module "contributor-access" {
  for_each          = toset(local.modernisation_platform_repositories)
  source            = "./modules/contributor"
  application_teams = local.application_github_slugs
  repository_id     = each.key
}
