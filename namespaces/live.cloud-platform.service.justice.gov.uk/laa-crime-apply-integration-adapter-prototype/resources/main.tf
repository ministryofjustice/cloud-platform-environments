terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
      tags = {
        business-unit          = var.business_unit
        application            = var.application
        is-production          = var.is_production
        environment-name       = var.environment_name
        owner                  = var.team_name
        infrastructure-support = var.infrastructure_support
        namespace              = var.namespace
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
