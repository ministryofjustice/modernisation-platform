# Repositories
module "core" {
  source       = "./modules/repository"
  type         = "core"
  name         = "modernisation-platform"
  description  = "A place for the core work of the Modernisation Platform"
  homepage_url = "https://user-guide.modernisation-platform.service.justice.gov.uk"
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
    SLACK_WEBHOOK_URL = data.aws_secretsmanager_secret_version.slack_webhook_url.secret_string
    # Pagerduty api token
    PAGERDUTY_TOKEN = data.aws_secretsmanager_secret_version.pagerduty_token.secret_string
  }))
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
  required_checks = ["Run Go Unit Tests"]
  secrets         = nonsensitive(local.testing_ci_iam_user_keys)
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
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
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
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "terraform-module-ecs" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-ecs"
  description = "Module for creating ECS cluster (Linux/Windows) solely for EC2 launch type"
  topics = [
    "aws",
    "ecs",
    "linux",
    "windows"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "modernisation-platform-ami-builds" {
  source      = "./modules/repository"
  name        = "modernisation-platform-ami-builds"
  description = "Modernisation platform AMI builds"
  topics = [
    "aws",
    "ami",
    "linux",
    "windows"
  ]
  secrets = nonsensitive(local.ci_iam_user_keys)
}

module "terraform-module-aws-vm-import" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-aws-vm-import"
  description = "Module to import virtual machine (VM) images from your virtualization environment to Amazon EC2 as Amazon Machine Images (AMI)"
  topics = [
    "aws",
    "vm",
    "linux",
    "windows"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "terraform-module-lambda-scheduler-stop-start" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-lambda-scheduler-stop-start"
  description = "Module for stopping and starting instance, rds resources and autoscaling groups with lambda function"
  topics = [
    "aws",
    "ec2",
    "rds",
    "autoscaling-groups",
    "lambda"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
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

module "modernisation-platform-infrastructure-test" {
  source      = "./modules/repository"
  name        = "modernisation-platform-infrastructure-test"
  description = "Infrastructure test tool based on Cucumber.js"
  topics = [
    "aws",
    "networking",
    "test",
    "moj-security"
  ]
}

module "terraform-module-aws-loadbalancer" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-loadbalancer"
  description = "Module that creates a loadbalancer in AWS with logging enabled"
  topics = [
    "aws",
    "linux",
    "loadbalancer",
    "logging"
  ]
}

module "modernisation-platform-terraform-member-vpc" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-member-vpc"
  description = "Module for member VPC accounts in the Modernisation Platform"
  topics = [
    "aws",
    "platform",
    "member-vpc"
  ]
}

module "modernisation-platform-cp-network-test" {
  source      = "./modules/repository"
  name        = "modernisation-platform-cp-network-test"
  description = "Simple network testing app to be deployed in Cloud Platform in order to test connectivity between the Cloud Platform and the Modernisation Platform"
  topics = [
    "aws",
    "testing",
    "networking"
  ]
}

module "modernisation-platform-terraform-module-template" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-module-template"
  type        = "template"
  description = "Template repository for creating Terraform modules for use with the Modernisation Platform"
  topics = [
    "aws",
    "terraform",
    "module"
  ]
}

module "modernisation-platform-terraform-pagerduty-integration" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-pagerduty-integration"
  description = "Module for integrating SNS topics with Pagerduty Services"
  topics = [
    "aws",
    "terraform",
    "module",
    "pagerduty",
    "alerting"
  ]
  required_checks = ["Run Go Unit Tests"]
  secrets         = nonsensitive(local.testing_ci_iam_user_keys)
}

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
    module.terraform-module-trusted-advisor.repository.name,
    module.terraform-module-bastion-linux.repository.name,
    module.terraform-module-ecs.repository.name,
    module.terraform-module-aws-vm-import.repository.name,
    module.terraform-module-lambda-scheduler-stop-start.repository.name,
    module.terraform-module-aws-loadbalancer.repository.name,
    module.modernisation-platform-ami-builds.repository.name,
    module.modernisation-platform-environments.repository.name,
    module.modernisation-platform-infrastructure-test.repository.name,
    module.modernisation-platform-terraform-member-vpc.repository.name,
    module.modernisation-platform-cp-network-test.repository.name,
    module.modernisation-platform-terraform-module-template.repository.name,
    module.modernisation-platform-terraform-pagerduty-integration.repository.name
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

# Give write access to teams on the AMI builds repo (access to merge to main is restricted by codeowners file)
resource "github_team_repository" "modernisation-platform-ami-builds-access" {
  for_each   = { for team in local.application_teams : team => team }
  team_id    = each.value
  repository = module.modernisation-platform-ami-builds.repository.id
  permission = "push"
}

# Give write access to teams on the environments repo (access to merge to main is restricted by codeowners file)
resource "github_team_repository" "modernisation-platform-environments-access" {
  for_each   = { for team in local.application_teams : team => team }
  team_id    = each.value
  repository = module.modernisation-platform-environments.repository.id
  permission = "push"
}
