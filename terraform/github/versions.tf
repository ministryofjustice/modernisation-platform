terraform {
  required_version = ">= 0.13"
  required_providers {
    github = {
      version = "4.0.0"
      source  = "hashicorp/github"
    }
  }
}
