terraform {
  backend "s3" {
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
  default_tags {
    tags = {
      business-unit = var.business_unit
      application   = var.application
      is-production = var.is_production
      owner         = var.team_name
      namespace     = var.namespace
      service-area  = var.service_area
      GithubTeam    = var.team_name
    }
  }
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
  default_tags {
    tags = {
      business-unit = var.business_unit
      application   = var.application
      is-production = var.is_production
      owner         = var.team_name
      namespace     = var.namespace
      service-area  = var.service_area
      GithubTeam    = var.team_name
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
