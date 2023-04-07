terraform {
  required_version = "~> 1.0"
  required_providers {
    github = {
      version = "5.21.1"
      source  = "integrations/github"
    }
  }
}
