terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.17.0"
    }
#    pingdom = {
#      source  = "DrFaust92/pingdom"
#      version = "~> 1.3.1"
#    }
#    random = {
#      source  = "hashicorp/random"
#      version = "~> 3.4.3"
#    }
#    kubernetes = {
#      source  = "hashicorp/kubernetes"
#      version = "~> 2.18.0"
#    }
  }
}
