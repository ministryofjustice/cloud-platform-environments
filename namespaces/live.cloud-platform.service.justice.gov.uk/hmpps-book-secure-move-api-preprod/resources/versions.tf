
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
