terraform {
  required_version = ">= 1.2.5"
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.39.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }
}
