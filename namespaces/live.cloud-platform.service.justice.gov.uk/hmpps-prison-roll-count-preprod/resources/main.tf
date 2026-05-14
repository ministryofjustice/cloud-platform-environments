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
    tags = {
      # see https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/accessing-the-cloud-console.html
      GithubTeam = var.team_name
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
    "business-unit"    = var.business_unit
    "service-area"     = var.service_area
    "application"      = var.application
    "is-production"    = var.is_production
    "environment-name" = var.environment
    "owner"            = var.team_name
    "namespace"        = var.namespace
    "source-code"      = "github.com/ministryofjustice/cloud-platform-environments"
    "slack-channel"    = var.slack_channel
    "GithubTeam"       = var.github_review_team
  }
}
