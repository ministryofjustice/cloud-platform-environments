
terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
    }
    github = {
      source = "integrations/github"
    }
    random = {
      version = "3.3.2"
    }
  }
}
