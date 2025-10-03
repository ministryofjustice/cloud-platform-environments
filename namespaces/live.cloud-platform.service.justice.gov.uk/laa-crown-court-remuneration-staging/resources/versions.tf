terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.39.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    pingdom = {
      source  = "DrFaust92/pingdom"
      version = "~> 1.3.1"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.2.4"
    }
  }
}
