terraform {
  required_providers {
    aws = {
      version               = ">= 3.47.0"
      source                = "hashicorp/aws"
      configuration_aliases = [aws.share-host, aws.share-tenant]
    }
  }
  required_version = ">= 1.0.1"
}
