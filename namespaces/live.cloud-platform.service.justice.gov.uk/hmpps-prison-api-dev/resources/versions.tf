terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.23.0"
    }
  }
}

