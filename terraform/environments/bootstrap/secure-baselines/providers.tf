# AWS provider (default): the MoJ root account. Required to create and assume roles into AWS accounts that are part of the AWS organisation
provider "aws" {
  region = "eu-west-2"
}

# AWS provider (Modernisation Platform): the Modernisation Platform account. Required to access secrets stored in the Modernisation Platform
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.modernisation_platform_account.id}:role/OrganizationAccountAccessRole"
  }
}

# AWS provider (workspace): the workspace account. Required for assuming a role into an account for bootstrapping
provider "aws" {
  alias  = "workspace"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

# Region specific providers for the workspace. Required for bootstrapping resources in all regions
provider "aws" {
  alias  = "workspace-ap-northeast-1"
  region = "ap-northeast-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-ap-northeast-2"
  region = "ap-northeast-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-ap-south-1"
  region = "ap-south-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-ap-southeast-1"
  region = "ap-southeast-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-ap-southeast-2"
  region = "ap-southeast-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-ca-central-1"
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-eu-central-1"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-eu-north-1"
  region = "eu-north-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-eu-west-1"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-eu-west-2"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-eu-west-3"
  region = "eu-west-3"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-sa-east-1"
  region = "sa-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-us-east-1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-us-east-2"
  region = "us-east-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-us-west-1"
  region = "us-west-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "workspace-us-west-2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}
