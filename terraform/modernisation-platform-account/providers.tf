# AWS providers
provider "aws" {
  region                 = "ap-northeast-1"
  alias                  = "modernisation-platform-ap-northeast-1"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "ap-northeast-2"
  alias                  = "modernisation-platform-ap-northeast-2"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "ap-south-1"
  alias                  = "modernisation-platform-ap-south-1"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "ap-southeast-1"
  alias                  = "modernisation-platform-ap-southeast-1"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "ap-southeast-2"
  alias                  = "modernisation-platform-ap-southeast-2"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "ca-central-1"
  alias                  = "modernisation-platform-ca-central-1"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "eu-central-1"
  alias                  = "modernisation-platform-eu-central-1"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "eu-north-1"
  alias                  = "modernisation-platform-eu-north-1"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "eu-west-1"
  alias                  = "modernisation-platform-eu-west-1"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "eu-west-2"
  alias                  = "modernisation-platform-eu-west-2"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "eu-west-3"
  alias                  = "modernisation-platform-eu-west-3"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "sa-east-1"
  alias                  = "modernisation-platform-sa-east-1"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "us-east-1"
  alias                  = "modernisation-platform-us-east-1"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "us-east-2"
  alias                  = "modernisation-platform-us-east-2"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "us-west-1"
  alias                  = "modernisation-platform-us-west-1"
  skip_get_ec2_platforms = true
}

provider "aws" {
  region                 = "us-west-2"
  alias                  = "modernisation-platform-us-west-2"
  skip_get_ec2_platforms = true
}

# AWS provider for core-logging
provider "aws" {
  alias  = "core-logging"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-logging-production"]}:role/ModernisationPlatformAccess"
  }
}
