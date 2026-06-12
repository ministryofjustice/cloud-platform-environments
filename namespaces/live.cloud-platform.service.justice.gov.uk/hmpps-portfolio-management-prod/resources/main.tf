terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      application   = var.application
      business-unit = var.business_unit
      GithubTeam    = var.team_name
      is-production = var.is_production
      namespace     = var.namespace
      owner         = var.team_name
      service-area  = var.service_area
      slack-channel = var.slack_channel
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      application   = var.application
      business-unit = var.business_unit
      GithubTeam    = var.team_name
      is-production = var.is_production
      namespace     = var.namespace
      owner         = var.team_name
      service-area  = var.service_area
      slack-channel = var.slack_channel
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      application   = var.application
      business-unit = var.business_unit
      GithubTeam    = var.team_name
      is-production = var.is_production
      namespace     = var.namespace
      owner         = var.team_name
      service-area  = var.service_area
      slack-channel = var.slack_channel
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
    }
  }
}

###########################################################
# Added by james - 2024-10-30 - intended to enable ssm to 
# be accessible through the AWS console

locals {
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}
###########################################################

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

provider "kubernetes" {}