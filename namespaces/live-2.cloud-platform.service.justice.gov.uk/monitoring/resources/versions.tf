terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
    pingdom = {
      source  = "russellcardullo/pingdom"
      version = "~> 1.1.3"
    }
  }
}
