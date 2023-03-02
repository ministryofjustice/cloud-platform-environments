terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.18.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.3.1"
    }
    pingdom = {
      source  = "russellcardullo/pingdom"
      version = "~> 1.1.3"
    }
  }
}
