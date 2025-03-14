# AWS provider for the workspace you're working in (every resource will default to using this, unless otherwise specified)
provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
  default_tags { tags = local.tags }
}

# AWS provider for the Modernisation Platform, to get things from there if required
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
  default_tags { tags = local.tags }
}

# AWS provider for core-vpc-<environment>, to share VPCs into this account
provider "aws" {
  alias  = "core-vpc"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[local.provider_name]}:role/ModernisationPlatformAccess"
  }
  default_tags { tags = local.tags }
}

# AWS provider for core-network-services-production, to share VPCs into this account
provider "aws" {
  alias  = "core-network-services"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/ModernisationPlatformAccess"
  }
  default_tags { tags = local.tags }
}

############################
# OpenID Connect providers #
############################

# Get secret by arn for environment management
data "aws_secretsmanager_secret" "mod_plat_circleci" {
  provider = aws.modernisation-secrets-read
  name     = "mod-platform-circleci"
}

data "aws_secretsmanager_secret_version" "circleci" {
  provider = aws.modernisation-secrets-read
  secret_id = data.aws_secretsmanager_secret.mod_plat_circleci.name
}
locals {
  secret_json  = jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)
  secret_value = local.secret_json.organisation_id
}

resource "aws_iam_openid_connect_provider" "circleci_oidc_provider" {
  url             = "https://oidc.circleci.com/org/${local.secret_json.organisation_id}"
  client_id_list  = [local.secret_json.organisation_id]
  thumbprint_list = distinct(concat(data.tls_certificate.circleci.certificates[*].sha1_fingerprint, var.circleci_known_thumbprints))

  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}

# AWS provider (modernisation-secrets-read): Required for assuming a role into modernisation platform account to read secrets
provider "aws" {
  alias  = "modernisation-secrets-read"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${data.aws_ssm_parameter.modernisation_platform_account_id.value}:role/modernisation-account-limited-read-member-access"
  }
}
