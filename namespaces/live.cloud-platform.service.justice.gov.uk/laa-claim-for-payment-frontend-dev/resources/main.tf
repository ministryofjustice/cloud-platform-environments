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

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = local.default_tags
  }
}

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

provider "kubernetes" {}

locals {
  default_tags = {
    "business-unit"    = var.business_unit
    "application"      = var.application
    "is-production"    = var.is_production
    "environment-name" = var.environment
    "owner"            = var.team_name
    "namespace"        = var.namespace
    "source-code"      = "https://github.com/ministryofjustice/laa-claim-for-payment-frontend"
    "slack-channel"    = var.slack_channel
    "GithubTeam"       = var.team_name
  }
}
