terraform {
  required_version = ">= 1.2.5"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.39.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "2.25.2"
    # }
    # random = {
    #   source  = "hashicorp/random"
    #   version = ">= 2.0.0"
    # }
  }
}
