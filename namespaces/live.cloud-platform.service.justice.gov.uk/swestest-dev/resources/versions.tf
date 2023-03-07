terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.17.0"
    }
  }
}
