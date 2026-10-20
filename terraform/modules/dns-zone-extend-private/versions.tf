terraform {
  required_providers {
    aws = {
      version               = "~> 6.0"
      source                = "hashicorp/aws"
      configuration_aliases = [aws.core-network-services, aws.core-vpc]
    }
  }
  required_version = "~> 1.0"
}
