terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      business-unit = var.business_unit
      application   = var.application
      is-production = var.is_production
      owner         = var.team_name
      namespace     = var.namespace
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
    }
  }
}

provider "kubernetes" {}
