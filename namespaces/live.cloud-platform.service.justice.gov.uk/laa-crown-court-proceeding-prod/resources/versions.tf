
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
    github = {
      source = "integrations/github"
    }
    pingdom = {
      source  = "russellcardullo/pingdom"
      version = "1.1.3"
    }
  }
}
