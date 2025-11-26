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
        GithubTeam = "hmpps-prison-visits-booking-devs"
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
        GithubTeam = "hmpps-prison-visits-booking-devs"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

