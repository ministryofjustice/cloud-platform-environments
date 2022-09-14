
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
        elasticsearch = {
      source  = "phillbaker/elasticsearch"
      version = "2.0.4"
    }
    github = {
      source = "integrations/github"
    }
  }
}
