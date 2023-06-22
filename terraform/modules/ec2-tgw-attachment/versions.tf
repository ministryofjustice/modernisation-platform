terraform {
  required_providers {
    aws = {
      version               = "~> 5.0"
      source                = "hashicorp/aws"
      configuration_aliases = [aws.transit-gateway-host, aws.transit-gateway-tenant]
    }
    time = {
      version = ">= 0.9.1"
      source  = "hashicorp/time"
    }
  }
  required_version = ">= 1.0.1"
}
