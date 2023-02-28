
terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
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
