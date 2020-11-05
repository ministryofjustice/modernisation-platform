terraform {
  required_version = ">= 0.13"
  required_providers {
    github = {
      version = "3.0.0" # Pin to 3.0.0 as 3.1.0 is currently broken (https://github.com/terraform-providers/terraform-provider-github/issues/566#issuecomment-720150093)
      source  = "hashicorp/github"
    }
  }
}
