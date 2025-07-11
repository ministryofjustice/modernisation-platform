terraform {
  required_providers {
    aws = {
      version = "~> 6.3"
      source  = "hashicorp/aws"
    }
    external = {
      version = "~> 2.0"
      source  = "hashicorp/external"
    }
  }
  required_version = "~> 1.0"
}
