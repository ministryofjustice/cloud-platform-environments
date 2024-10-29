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
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}
