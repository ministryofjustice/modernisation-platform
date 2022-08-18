terraform {
  required_providers {
    aws = {
      version = ">= 4.0.0, < 5.0.0"
      source  = "hashicorp/aws"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
  required_version = "~> 1.0"
}
