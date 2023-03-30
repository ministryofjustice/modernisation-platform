# ######################### Run Terraform via CICD ##################################
# AWS provider for the workspace you're working in (every resource will default to using this, unless otherwise specified)
provider "aws" {
  alias  = "original-session"
  region = "eu-west-2"
}

provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${data.aws_caller_identity.original_session.id}:role/MemberInfrastructureAccess"
  }
}

# AWS provider for the Modernisation Platform, to get things from there if required
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.modernisation_platform_account_id}:role/modernisation-account-limited-read-member-access"
  }
}

# AWS provider for core-vpc-<environment>, to share VPCs into this account
provider "aws" {
  alias  = "core-vpc"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[local.provider_name]}:role/member-delegation-${local.vpc_name}-${local.environment}"
  }
}

# AWS provider for network services to enable dns entries for certificate validation to be created
provider "aws" {
  alias  = "core-network-services"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/modify-dns-records"
  }
}

# AWS provider for the ACM usage in us-east-1
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${data.aws_caller_identity.original_session.id}:role/MemberInfrastructureAccessUSEast"
  }
}

######################### Run Terraform via CICD ##################################


######################### Run Terraform Plan Locally Only ##################################
# # To run a Terraform Plan locally, uncomment this bottom section of code and comment out the top section

# provider "aws" {
#   region = "eu-west-2"
# }

# provider "aws" {
#   alias  = "original-session"
#   region = "eu-west-2"
# }

# # AWS provider for the Modernisation Platform, to get things from there if required
# provider "aws" {
#   alias                  = "modernisation-platform"
#   region                 = "eu-west-2"
#   assume_role {
#     role_arn = "arn:aws:iam::${local.modernisation_platform_account_id}:role/modernisation-account-limited-read-member-access"
#   }
# }

# # AWS provider for core-vpc-<environment>, to share VPCs into this account
# provider "aws" {
#   alias  = "core-vpc"
#   region = "eu-west-2"

#   assume_role {
#     role_arn = "arn:aws:iam::${local.environment_management.account_ids[local.provider_name]}:role/member-delegation-read-only"
#   }
# }

# # AWS provider for network services to enable dns entries for certificate validation to be created
# provider "aws" {
#   alias  = "core-network-services"
#   region = "eu-west-2"

#   assume_role {
#     role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/read-dns-records"
#   }
# }
######################### Run Terraform Plan Locally Only ##################################
