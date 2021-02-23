terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  required_version = ">= 0.13"
}
