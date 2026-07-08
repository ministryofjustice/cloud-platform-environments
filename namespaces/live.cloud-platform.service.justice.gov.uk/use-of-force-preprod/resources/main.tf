terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = local.default_tags
  }
}

# To be use in case the resources need to be created in London
provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = local.default_tags
  }
}

# To be use in case the resources need to be created in Ireland
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = local.default_tags
  }
}
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

locals {
  default_tags = {
    "business-unit"    = var.business_unit
    "service-area"     = var.service_area
    "application"      = var.application
    "is-production"    = var.is_production
    "environment-name" = var.environment
    "owner"            = var.team_name
    "namespace"        = var.namespace
    "source-code"      = "github.com/ministryofjustice/cloud-platform-environments"
    "slack-channel"    = var.slack_channel
    "GithubTeam"       = var.review_team_name
  }
}
