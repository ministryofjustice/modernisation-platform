# Repositories
module "core" {
  source       = "./modules/repository"
  name         = "modernisation-platform"
  type         = "core"
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
  type        = "module"
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
  type        = "module"
  description = "Module for creating an IAM role that can be assumed from another account"
  topics = [
    "aws",
    "iam"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "terraform-module-environments" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-environments"
  type        = "module"
  description = "Module for creating organizational units and accounts within AWS Organizations from JSON files"
  topics = [
    "organizational-units",
    "aws"
  ]
}

module "terraform-module-iam-superadmins" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-iam-superadmins"
  type        = "module"
  description = "Module for creating defined IAM users as superadmins"
  topics = [
    "aws",
    "iam"
  ]
}

module "terraform-module-s3-bucket-replication-role" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-s3-bucket-replication-role"
  type        = "module"
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
  type        = "module"
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
  type        = "module"
  description = "Module for refreshing Trusted Advisor every 60 minutes"
  topics = [
    "aws",
    "trusted-advisor"
  ]
}

module "terraform-module-bastion-linux" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-bastion-linux"
  type        = "module"
  description = "Module for creating Linux bastion servers in member AWS accounts"
  topics = [
    "aws",
    "bastion",
    "linux"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "terraform-module-github-oidc-provider" {
  source      = "./modules/repository"
  name        = "modernisation-platform-github-oidc-provider"
  type        = "module"
  description = "Module for creating OIDC providers to use in GitHub Actions"
  topics = [
    "aws",
    "oidc",
    "github",
    "actions"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "terraform-module-github-oidc-role" {
  source      = "./modules/repository"
  name        = "modernisation-platform-github-oidc-role"
  type        = "module"
  description = "Module for creating additional roles assumable via the OIDC provider for use in Github Actions"
  topics = [
    "aws",
    "oidc",
    "github",
    "actions"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "terraform-module-ecs" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-ecs"
  type        = "module"
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
  type        = "core"
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
  type        = "module"
  description = "Module to import virtual machine (VM) images from your virtualization environment to Amazon EC2 as Amazon Machine Images (AMI)"
  topics = [
    "aws",
    "vm",
    "linux",
    "windows"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "modernisation-platform-instance-scheduler" {
  source      = "./modules/repository"
  name        = "modernisation-platform-instance-scheduler"
  type        = "core"
  description = "A Go lambda function for stopping and starting instance, rds resources and autoscaling groups"
  topics = [
    "aws",
    "ec2",
    "rds",
    "autoscaling-groups",
    "lambda"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "terraform-module-ssm-patching" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-ssm-patching"
  type        = "module"
  description = "Module to automate the patching of ec2 instances in each account"
  topics = [
    "aws",
    "iam",
    "ssm",
    "moj-security"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "terraform-module-lambda-function" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-lambda-function"
  type        = "module"
  description = "Module to deploy lambda functions in modernisation platform accounts"
  topics = [
    "aws",
    "iam",
    "lambda"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "modernisation-platform-environments" {
  source      = "./modules/repository"
  name        = "modernisation-platform-environments"
  type        = "core"
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
  type        = "core"
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
  type        = "module"
  description = "Module that creates a loadbalancer in AWS with logging enabled"
  topics = [
    "aws",
    "linux",
    "loadbalancer",
    "logging"
  ]
  required_checks = ["Run Go Unit Tests"]
  secrets         = nonsensitive(local.testing_ci_iam_user_keys)
}

module "modernisation-platform-terraform-member-vpc" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-member-vpc"
  type        = "module"
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
  type        = "core"
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
  type        = "module"
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

module "modernisation-platform-configuration-management" {
  source      = "./modules/repository"
  name        = "modernisation-platform-configuration-management"
  type        = "core"
  description = "Repository for configuration management code used to manage and maintain ec2 infrastructure hosted in the Modernisation Platform"
  topics = [
    "aws",
    "configuration-management",
    "ansible",
    "ec2"
  ]
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
    module.modernisation-platform-instance-scheduler.repository.name,
    module.terraform-module-aws-loadbalancer.repository.name,
    module.modernisation-platform-ami-builds.repository.name,
    module.modernisation-platform-environments.repository.name,
    module.modernisation-platform-infrastructure-test.repository.name,
    module.modernisation-platform-terraform-member-vpc.repository.name,
    module.modernisation-platform-cp-network-test.repository.name,
    module.modernisation-platform-terraform-module-template.repository.name,
    module.modernisation-platform-terraform-pagerduty-integration.repository.name,
    module.terraform-module-github-oidc-provider.repository.name,
    module.terraform-module-github-oidc-role.repository.name,
    module.modernisation-platform-configuration-management.repository.name,
    module.terraform-module-lambda-function.repository.name,
    module.terraform-module-ssm-patching.repository.name
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

module "contributor-access" {
  for_each          = toset(local.modernisation_platform_repositories)
  source            = "./modules/contributor"
  application_teams = local.application_teams
  repository_id     = each.key
}