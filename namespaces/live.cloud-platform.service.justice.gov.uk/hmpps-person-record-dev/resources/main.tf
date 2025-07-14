terraform {
  backend "s3" {
  }
}
provider "aws" {
  region = "eu-west-2"
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

locals {
  default_tags = {
    namespace              = var.namespace
    business-unit          = var.business_unit
    service-area           = var.service_area
    application            = var.application
    is-production          = var.is_production
    team-name              = var.team_name
    environment-name       = var.environment
    owner                  = var.owner
    infrastructure-support = var.infrastructure_support
  }
}
