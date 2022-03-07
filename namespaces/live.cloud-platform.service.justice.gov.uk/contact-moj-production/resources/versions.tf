
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.68.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    pingdom = {
      source  = "russellcardullo/pingdom"
      version = "1.1.3"
    }
    github = {
      source = "integrations/github"
    }
  }
}
