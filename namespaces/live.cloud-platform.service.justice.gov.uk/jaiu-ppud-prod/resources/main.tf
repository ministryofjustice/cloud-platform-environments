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

# Keep the supported ECR module's GitHub provider constrained; its repository
# integration is disabled, so this provider creates no GitHub resources.
provider "github" {}

provider "kubernetes" {}
