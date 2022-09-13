
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
    }
    github = {
      source = "integrations/github"
    }
    random = {
      version = "3.3.2"
    }
    elasticsearch = {
      source  = "phillbaker/elasticsearch"
      version = "2.0.4"
    }
  }
}
