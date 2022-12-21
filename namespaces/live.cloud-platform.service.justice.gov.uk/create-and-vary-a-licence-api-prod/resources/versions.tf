
terraform {
  required_version = ">= 0.14"
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
  }
}
