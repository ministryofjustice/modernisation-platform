terraform {
  required_providers {
    aws = {
      version = "5.38.0" #pinned temporarily due to rate limiting bug #6486
      source  = "hashicorp/aws"
    }
  }
  required_version = "~> 1.0"
}
