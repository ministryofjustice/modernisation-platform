terraform {
  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
    archive = {
<<<<<<< HEAD
      version = "~> 2.2"
=======
      version = "~> 2.0"
>>>>>>> main
      source  = "hashicorp/archive"
    }
  }
  required_version = "~> 1.0"
}
