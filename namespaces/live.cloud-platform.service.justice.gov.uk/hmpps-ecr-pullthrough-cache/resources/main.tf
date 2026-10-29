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
    }
  }
}
