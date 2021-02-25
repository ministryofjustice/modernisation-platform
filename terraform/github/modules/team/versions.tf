terraform {
  required_version = ">= 0.14.2"
  required_providers {
    github = {
      version = ">= 4.4.0"
      source  = "integrations/github"
    }
  }
}
