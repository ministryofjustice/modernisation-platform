terraform {
  # `backend` blocks do not support variables, so the following are hard-coded here:
  # - S3 bucket name, which is created in global-resources/s3.tf
  backend "s3" {
    bucket  = "modernisation-platform-terraform-state"
    encrypt = true
    key     = "github/terraform.tfstate"
    region  = "eu-west-2"
  }
}

provider "github" {
  owner = "ministryofjustice"
}

# Repositories
module "core" {
  source      = "./modules/repository"
  type        = "core"
  name        = "modernisation-platform"
  description = "A place for the public work of the Modernisation Platform"
  topics = [
    "architecture-decisions",
    "aws",
    "documentation"
  ]
}

module "terraform-module-baselines" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-baselines"
  description = "A Modernisation Platform-specific configuration of the MoJ Security Guidance AWS account baselines"
  topics = [
    "aws",
    "moj-security"
  ]
}

module "terraform-module-cross-account-access" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-cross-account-access"
  description = "A simple Terraform module for allowing cross-account access"
  topics = [
    "aws",
    "iam"
  ]
}

module "terraform-module-environments" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-environments"
  description = "A proof of concept for provisioning additional environment-based OUs with attached accounts within the Modernisation Platform"
  topics = [
    "organizational-units",
    "aws"
  ]
}

module "terraform-module-iam-superadmins" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-iam-superadmins"
  description = "A Terraform module for setting up Modernisation Platform superadmins on an account by account basis"
  topics = [
    "aws",
    "iam"
  ]
}

module "terraform-module-s3-bucket-replication-role" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-s3-bucket-replication-role"
  description = "Terraform module for creating an S3 bucket replication role based on bucket ARNs"
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
  description = "A Terraform module for standardised S3 bucket creation."
  topics = [
    "aws",
    "s3",
    "s3-replication"
  ]
}

# Teams and their access to the above repositories
module "core-team" {
  source      = "./modules/team"
  name        = "modernisation-platform"
  description = "Modernisation Platform team"
  repositories = [
    module.core.repository.id,
    module.terraform-module-baselines.repository.id,
    module.terraform-module-cross-account-access.repository.id,
    module.terraform-module-environments.repository.id,
    module.terraform-module-iam-superadmins.repository.id,
    module.terraform-module-s3-bucket-replication-role.repository.id,
    module.terraform-module-s3-bucket.repository.id
  ]
}
