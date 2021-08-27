# Repositories
module "core" {
  source       = "./modules/repository"
  type         = "core"
  name         = "modernisation-platform"
  description  = "A place for the core work of the Modernisation Platform"
  homepage_url = "https://ministryofjustice.github.io/modernisation-platform"
  topics = [
    "architecture-decisions",
    "aws",
    "documentation"
  ]
  secrets = nonsensitive(merge(local.ci_iam_user_keys, {
    PRIVILEGED_AWS_ACCESS_KEY_ID     = "example"
    PRIVILEGED_AWS_SECRET_ACCESS_KEY = "example"
    # Terraform GitHub token for the CI/CD user
    TERRAFORM_GITHUB_TOKEN = "This needs to be manually set in GitHub."
    # Slack app webhook url
    SLACK_WEBHOOK_URL = "This needs to be manually set in GitHub."
  }))
}

module "hello-world" {
  source      = "./modules/repository"
  type        = "core"
  name        = "modernisation-platform-hello-world"
  description = "A sample application configuration within the Modernisation Platform"
  topics      = ["sample-code"]
}

module "terraform-module-baselines" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-baselines"
  description = "Module for enabling and configuring common baseline services such as SecurityHub"
  topics = [
    "aws",
    "aws-baselines",
    "moj-security",
  ]
}

module "terraform-module-cross-account-access" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-cross-account-access"
  description = "Module for creating an IAM role that can be assumed from another account"
  topics = [
    "aws",
    "iam"
  ]
}

module "terraform-module-environments" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-environments"
  description = "Module for creating organizational units and accounts within AWS Organizations from JSON files"
  topics = [
    "organizational-units",
    "aws"
  ]
}

module "terraform-module-iam-superadmins" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-iam-superadmins"
  description = "Module for creating defined IAM users as superadmins"
  topics = [
    "aws",
    "iam"
  ]
}

module "terraform-module-s3-bucket-replication-role" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-s3-bucket-replication-role"
  description = "Module for creating an IAM role for S3 bucket replication"
  topics = [
    "aws",
    "s3",
    "s3-replication",
    "iam"
  ]
}

module "terraform-module-s3-bucket" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-s3-bucket"
  description = "Module for creating S3 buckets with sensible defaults e.g. replication, encryption"
  topics = [
    "aws",
    "s3",
    "s3-replication"
  ]
}

module "terraform-module-trusted-advisor" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-trusted-advisor"
  description = "Module for refreshing Trusted Advisor every 60 minutes"
  topics = [
    "aws",
    "trusted-advisor"
  ]
}

module "terraform-module-bastion-linux" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-bastion-linux"
  description = "Module for creating Linux bastion servers in member AWS accounts"
  topics = [
    "aws",
    "bastion",
    "linux"
  ]
}

module "terraform-module-ecs" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-ecs"
  description = "Module for creating ECS cluster (Linux/Windows) solely for EC2 launch type"
  topics = [
    "aws",
    "ecs",
    "linux"
    "windows"
  ]
}

module "modernisation-platform-environments" {
  source      = "./modules/repository"
  name        = "modernisation-platform-environments"
  description = "Modernisation platform environments"
  topics = [
    "aws",
    "environments"
  ]
  required_checks = ["run-opa-policy-tests"]
  secrets = nonsensitive(merge(local.member_ci_iam_user_keys, {
    # Terraform GitHub token for the CI/CD user
    TERRAFORM_GITHUB_TOKEN = "This needs to be manually set in GitHub."
  }))
}

# Everyone, with access to the above repositories
module "core-team" {
  source      = "./modules/team"
  name        = "modernisation-platform"
  description = "Modernisation Platform team"
  repositories = [
    module.core.repository.name,
    module.hello-world.repository.name,
    module.terraform-module-baselines.repository.name,
    module.terraform-module-cross-account-access.repository.name,
    module.terraform-module-environments.repository.name,
    module.terraform-module-iam-superadmins.repository.name,
    module.terraform-module-s3-bucket-replication-role.repository.name,
    module.terraform-module-s3-bucket.repository.name,
    module.terraform-module-trusted-advisor.repository.name,
    module.terraform-module-bastion-linux.repository.name,
    module.terraform-module-ecs.repository.name,
    module.modernisation-platform-environments.repository.name
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
