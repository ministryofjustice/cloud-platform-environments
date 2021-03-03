
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    pingdom = {
    random = {
      source = "hashicorp/random"
      source = "russellcardullo/pingdom"
      version = "1.1.3"
    }
  }
}
