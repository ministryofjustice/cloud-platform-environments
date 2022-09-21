
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source   = "hashicorp/aws"
      vversion = "~> 4.29.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
