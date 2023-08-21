terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      GithubTeam = "secure-estate-digital-team"
    }
  }
}

provider "random" {}
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

locals {
  default_tags = {
    namespace              = var.namespace
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}