
terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
    http = {
      source = "hashicorp/http"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}