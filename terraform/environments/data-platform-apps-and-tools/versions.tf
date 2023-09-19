terraform {
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
    http = {
      version = "~> 3.0"
      source  = "hashicorp/http"
    }
    time = {
      version = "~> 0.9"
      source  = "hashicorp/time"
    }
    tls = {
      version = "~> 4.0"
      source  = "hashicorp/tls"
    }
  }
  required_version = "~> 1.0"
}
