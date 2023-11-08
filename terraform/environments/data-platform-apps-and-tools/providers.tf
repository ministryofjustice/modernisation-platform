# AWS provider for the workspace you're working in (every resource will default to using this, unless otherwise specified)
provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
}

# AWS provider for the Modernisation Platform, to get things from there if required
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
}

# AWS provider for core-vpc-<environment>, to share VPCs into this account
provider "aws" {
  alias  = "core-vpc"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[local.provider_name]}:role/ModernisationPlatformAccess"
  }
}

# AWS provider for core-network-services-production, to share VPCs into this account
provider "aws" {
  alias  = "core-network-services"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/ModernisationPlatformAccess"
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "bash"
    args        = ["scripts/eks-authentication.sh", local.environment_management.account_ids[terraform.workspace], module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "bash"
      args        = ["scripts/eks-authentication.sh", local.environment_management.account_ids[terraform.workspace], module.eks.cluster_name]
    }
  }
}

provider "auth0" {
  domain        = data.aws_secretsmanager_secret_version.auth0_domain.secret_string
  client_id     = data.aws_secretsmanager_secret_version.auth0_client_id.secret_string
  client_secret = data.aws_secretsmanager_secret_version.auth0_client_secret.secret_string
}