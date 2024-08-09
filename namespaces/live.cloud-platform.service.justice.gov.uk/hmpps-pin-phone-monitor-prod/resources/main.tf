terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  # Allow resources to be visible to secure-estate-digital-team
  default_tags {
    tags = {
      GithubTeam = "secure-estate-digital-team"
    }
  }
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
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}
