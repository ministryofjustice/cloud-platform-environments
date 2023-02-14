terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      application            = var.application
      business-unit          = var.business_unit
      environment-name       = var.environment
      infrastructure-support = var.infrastructure_support
      is-production          = var.is_production
      namespace              = var.namespace
      team_name              = var.team_name
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      application            = var.application
      business-unit          = var.business_unit
      environment-name       = var.environment
      infrastructure-support = var.infrastructure_support
      is-production          = var.is_production
      namespace              = var.namespace
      team_name              = var.team_name
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
      application            = var.application
      business-unit          = var.business_unit
      environment-name       = var.environment
      infrastructure-support = var.infrastructure_support
      is-production          = var.is_production
      namespace              = var.namespace
      team_name              = var.team_name
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
