
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.68.0"
    }
    github = {
      source = "integrations/github"
    }
    pingdom = {
      source = "russellcardullo/pingdom"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}
