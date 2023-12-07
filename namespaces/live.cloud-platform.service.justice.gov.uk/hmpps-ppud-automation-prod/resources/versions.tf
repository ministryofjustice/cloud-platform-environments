
terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.39.0"
    }
    pingdom = {
      source  = "DrFaust92/pingdom"
      version = "~> 1.3.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }
}
