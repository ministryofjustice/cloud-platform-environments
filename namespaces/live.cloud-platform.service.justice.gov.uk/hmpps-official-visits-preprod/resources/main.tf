terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      application   = var.application
      business-unit = var.business_unit
      GithubTeam    = var.team_name
      is-production = var.is_production
      namespace     = var.namespace
      owner         = var.team_name
      service-area  = var.service_area
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      application   = var.application
      business-unit = var.business_unit
      GithubTeam    = var.team_name
      is-production = var.is_production
      namespace     = var.namespace
      owner         = var.team_name
      service-area  = var.service_area
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
      application   = var.application
      business-unit = var.business_unit
      GithubTeam    = var.team_name
      is-production = var.is_production
      namespace     = var.namespace
      owner         = var.team_name
      service-area  = var.service_area
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

provider "kubernetes" {}

locals {
    default_tags = {
    business_unit = var.business_unit
    application = var.application
    is_production = var.is_production
    team_name = var.team_name
    environment_name = var.environment
    infrastructure_support = var.infrastructure_support
    }
}
