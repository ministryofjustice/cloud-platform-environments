terraform {
  backend "s3" {
  }
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
      service-area  = var.service_area
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
      GithubTeam    = "info-advice-datastore"
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      business-unit = var.business_unit
      application   = var.application
      is-production = var.is_production
      owner         = var.team_name
      namespace     = var.namespace
      service-area  = var.service_area
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
      GithubTeam    = "info-advice-datastore"
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
      business-unit = var.business_unit
      application   = var.application
      is-production = var.is_production
      owner         = var.team_name
      namespace     = var.namespace
      service-area  = var.service_area
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

# Kept temporarily (not reverted) so Terraform can destroy the
# postgresql_grant_role.rds_iam resource that is being removed as part of
# the IRSA revert (MEM-1138). Remove this provider block in a follow-up PR
# once the destroy has been applied and the resource is confirmed gone
# from state.
provider "postgresql" {
  host      = module.rds.rds_instance_address
  port      = module.rds.rds_instance_port
  database  = module.rds.database_name
  username  = module.rds.database_username
  password  = module.rds.database_password
  sslmode   = "require"
  superuser = false
}

provider "kubernetes" {}
