terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "~> 3.2.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.1"
    }
    pingdom = {
      source  = "russellcardullo/pingdom"
      version = "~> 1.1.3"
    }
  }
}
