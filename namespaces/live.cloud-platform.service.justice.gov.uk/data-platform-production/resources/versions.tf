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
    /* Commenting out to satisfy tflint, but is part of Cloud Platform's template, and we might use it again in the future
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20.0"
    }
    */
  }
}
