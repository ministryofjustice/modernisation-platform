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
  secrets = {
    # Terraform GitHub token for the CI/CD user
    TERRAFORM_GITHUB_TOKEN = data.aws_secretsmanager_secret_version.github_ci_user_token.secret_string
    # Slack app webhook url
    SLACK_WEBHOOK_URL = data.aws_secretsmanager_secret_version.slack_webhook_url.secret_string
    # Pagerduty api token
    PAGERDUTY_TOKEN = data.aws_secretsmanager_secret_version.pagerduty_token.secret_string
    # Pagerduty User api token
    PAGERDUTY_USERAPI_TOKEN = data.aws_secretsmanager_secret_version.pagerduty_user_token.secret_string
  }
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
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
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
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
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

module "terraform-module-ecs-cluster" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-ecs-cluster"
  type        = "module"
  description = "Module for creating ECS cluster (Linux/Windows) not just for EC2 launch type"
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

module "terraform-module-ec2-autoscaling-group" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-ec2-autoscaling-group"
  type        = "module"
  description = "Module for ec2 autoscaling"
  topics = [
    "aws",
    "iam",
    "ec2",
    "moj-security"
  ]
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
}

module "terraform-module-ec2-instance" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-ec2-instance"
  type        = "module"
  description = "Module for ec2 instances"
  topics = [
    "aws",
    "iam",
    "ec2",
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
  secrets = {
    # Terraform GitHub token for the CI/CD user
    TERRAFORM_GITHUB_TOKEN                               = data.aws_secretsmanager_secret_version.github_ci_user_token.secret_string
    MODERNISATION_PLATFORM_CI_USER_ENVIRONMENTS_REPO_PAT = data.aws_secretsmanager_secret_version.github_ci_user_environments_repo_pat_token.secret_string
    MODERNISATION_PLATFORM_ACCOUNT_ID                    = local.modernisation_platform_account
    TESTING_AWS_ACCESS_KEY_ID                            = local.testing_ci_iam_user_keys.AWS_ACCESS_KEY_ID
    TESTING_AWS_SECRET_ACCESS_KEY                        = local.testing_ci_iam_user_keys.AWS_SECRET_ACCESS_KEY
  }
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
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
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
  secrets = nonsensitive(local.testing_ci_iam_user_keys)
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

module "modernisation-platform-incident-response" {
  source      = "./modules/repository"
  name        = "modernisation-platform-incident-response"
  type        = "core"
  description = "Repository for incident management code used to manage and document Modernisation Platform incidents. Originally forked from https://github.com/ministryofjustice/opg-incident-response"
  topics = [
    "incident-management",
    "javascript",
    "python",
    "django",
    "docker",
    "kubernetes",
    "helm"
  ]
}
module "modernisation-platform-terraform-dns-certificates" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-dns-certificates"
  type        = "module"
  description = "Module for creating route 53 dns entries and certificates to go with them"
  topics = [
    "aws",
    "dns",
    "terraform",
    "networking"
  ]
}
