terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
}

# To be use in case the resources need to be created in London
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

# To be use in case the resources need to be created in Ireland
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "probation-integration"
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam = "probation-integration"
    }
  }
}

provider "github" {
  owner = "ministryofjustice"
  token = var.github_token
}

locals {
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}