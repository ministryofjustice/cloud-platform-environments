
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    github = {
      source = "integrations/github"
    }
    pingdom = {
      source = "russellcardullo/pingdom"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.14.0"
    }
  }
}
