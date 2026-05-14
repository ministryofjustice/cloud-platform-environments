terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam = var.team_name
      business-unit = var.business_unit
      application = var.application
      is-production = var.is_production
      owner = "${var.team_name}: probation-integration@JusticeUK.onmicrosoft.com"
      namespace = var.namespace
      service-area = var.service_area
      slack-channel = var.slack_channel
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
