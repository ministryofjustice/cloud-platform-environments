terraform {
  backend "s3" {
  }
}

provider "aws" {
  default_tags {
    tags = {
      business-unit = var.business_unit
      application = var.application
      is-production = var.is_production
      owner = var.team_name
      namespace = var.namespace
      service-area = var.service_area
    }
  }
  region = "eu-west-2"
}

provider "aws" {
  default_tags {
    tags = {
      business-unit = var.business_unit
      application = var.application
      is-production = var.is_production
      owner = var.team_name
      namespace = var.namespace
      service-area = var.service_area
    }
  }
  alias  = "london"
  region = "eu-west-2"
}

provider "aws" {
  default_tags {
    tags = {
      business-unit = var.business_unit
      application = var.application
      is-production = var.is_production
      owner = var.team_name
      namespace = var.namespace
      service-area = var.service_area
    }
  }
  alias  = "ireland"
  region = "eu-west-1"
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
