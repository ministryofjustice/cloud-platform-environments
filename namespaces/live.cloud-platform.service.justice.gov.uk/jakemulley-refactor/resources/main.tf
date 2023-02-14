terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      # Mandatory
      business-unit = var.business_unit
      application   = var.application
      is-production = var.is_production
      owner         = var.team_name
      # Optional
      environment-name       = var.environment
      infrastructure-support = var.infrastructure_support
      source-code            = "github.com/ministryofjustice/cloud-platform-environments"
      # Custom
      namespace     = var.namespace
      slack-channel = var.slack_channel
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      # Mandatory
      business-unit = var.business_unit
      application   = var.application
      is-production = var.is_production
      owner         = var.team_name
      # Optional
      environment-name       = var.environment
      infrastructure-support = var.infrastructure_support
      source-code            = "github.com/ministryofjustice/cloud-platform-environments"
      # Custom
      namespace     = var.namespace
      slack-channel = var.slack_channel
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
      # Mandatory
      business-unit = var.business_unit
      application   = var.application
      is-production = var.is_production
      owner         = var.team_name
      # Optional
      environment-name       = var.environment
      infrastructure-support = var.infrastructure_support
      source-code            = "github.com/ministryofjustice/cloud-platform-environments"
      # Custom
      namespace     = var.namespace
      slack-channel = var.slack_channel
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
