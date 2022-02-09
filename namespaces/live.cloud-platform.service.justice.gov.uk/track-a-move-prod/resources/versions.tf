
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
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