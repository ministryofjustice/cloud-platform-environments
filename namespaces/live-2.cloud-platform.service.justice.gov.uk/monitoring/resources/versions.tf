terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
    pingdom = {
      source  = "DrFaust92/pingdom"
      version = "~> 1.3.1"
    }
  }
}
