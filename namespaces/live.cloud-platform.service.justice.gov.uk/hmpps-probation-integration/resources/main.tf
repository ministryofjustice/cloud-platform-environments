terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam    = var.team_name
      business-unit = var.business_unit
      application   = var.application
      is-production = var.is_production
      owner         = var.team_name
      namespace     = var.namespace
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
