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
    pingdom = {
      source  = "russellcardullo/pingdom"
      version = "1.1.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.3.1"
    }
  }
}
