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
    grafana = {
      source  = "grafana/grafana"
      version = "2.6.1"
    }
  }
  required_version = "~> 1.0"
}
