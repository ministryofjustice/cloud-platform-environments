terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      business-unit = var.business_unit
      application = var.application
      is-production = var.is_production
      owner = var.team_name
      namespace = var.namespace
      service-area = var.service_area
      # see https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/accessing-the-cloud-console.html
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
      GithubTeam    = var.team_name
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      business-unit = var.business_unit
      application = var.application
      is-production = var.is_production
      owner = var.team_name
      namespace = var.namespace
      service-area = var.service_area
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
      GithubTeam    = var.team_name
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
      business-unit = var.business_unit
      application = var.application
      is-production = var.is_production
      owner = var.team_name
      namespace = var.namespace
      service-area = var.service_area
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
      GithubTeam    = var.team_name
    }
  }
}
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

provider "kubernetes" {}

locals {
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment            = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}
