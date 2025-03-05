# AWS provider for the original session which you connect with
provider "aws" {
  alias  = "original-session"
  region = "eu-west-2"
  default_tags { tags = local.tags }
}

# AWS provider for the workspace you're working in (every resource will default to using this, unless otherwise specified)
provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = !can(regex("githubactionsrolesession|AdministratorAccess|user", data.aws_caller_identity.original_session.arn)) ? null : can(regex("user", data.aws_caller_identity.original_session.arn)) ? "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/${var.collaborator_access}" : "arn:aws:iam::${data.aws_caller_identity.original_session.id}:role/MemberInfrastructureAccess"
  }
  default_tags { tags = local.tags }
}

# AWS provider for the Modernisation Platform, to get things from there if required
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.modernisation_platform_account_id}:role/modernisation-account-limited-read-member-access"
  }
  default_tags { tags = local.tags }
}

# AWS provider for core-vpc-<environment>, to access resources in the core-vpc accounts
provider "aws" {
  alias  = "core-vpc"
  region = "eu-west-2"
  assume_role {
    role_arn = !can(regex("githubactionsrolesession|AdministratorAccess", data.aws_caller_identity.original_session.arn)) ? "arn:aws:iam::${local.environment_management.account_ids[local.provider_name]}:role/member-delegation-read-only" : "arn:aws:iam::${local.environment_management.account_ids[local.provider_name]}:role/member-delegation-${local.vpc_name}-${local.environment}"
  }
  default_tags { tags = local.tags }
}

# AWS provider for network services to enable dns entries for certificate validation to be created
provider "aws" {
  alias  = "core-network-services"
  region = "eu-west-2"
  assume_role {
    role_arn = !can(regex("githubactionsrolesession|AdministratorAccess", data.aws_caller_identity.original_session.arn)) ? "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/read-log-records" : "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/modify-dns-records"
  }
  default_tags { tags = local.tags }
}

# Provider for creating resources in us-east-1, eg ACM resources for CloudFront
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  assume_role {
    role_arn = !can(regex("githubactionsrolesession|AdministratorAccess|user", data.aws_caller_identity.original_session.arn)) ? null : can(regex("user", data.aws_caller_identity.original_session.arn)) ? "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/${var.collaborator_access}" : "arn:aws:iam::${data.aws_caller_identity.original_session.id}:role/MemberInfrastructureAccessUSEast"
  }
  default_tags { tags = local.tags }
}

# Provider for reading resources from root account IdentityStore
provider "aws" {
  region = "eu-west-2"
  alias  = "sso-readonly"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.aws_organizations_root_account_id}:role/ModernisationPlatformSSOReadOnly"
  }
  default_tags { tags = local.tags }
}
