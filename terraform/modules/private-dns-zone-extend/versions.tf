#provider information for the module
terraform {
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
      configuration_aliases = [aws.core-network-services, aws.core-vpc]
    }
  }
  required_version = "~> 1.0"
}