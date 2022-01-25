
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    pingdom = {
      source  = "russellcardullo/pingdom"
      version = "1.1.3"
    }
  }
}
