terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      # see https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/accessing-the-cloud-console.html
      GithubTeam = var.team_name
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      # see https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/accessing-the-cloud-console.html
      GithubTeam = var.team_name
    }
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

provider "aws" {
  alias  = "secrets"
  region = "eu-west-2"

  #assume_role {
    # Assumes the CP intermediary role (intra-account) which has direct access to the
    # MP secret via a resource-based policy on the secret. This avoids cross-account
    # sts:AssumeRole which is blocked by SCPs on the shared manager-concourse user.
    #role_arn     = "arn:aws:iam::754256621582:role/arns-dev-mp-secrets-access"
    #session_name = "terraform"
  #}
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
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}
