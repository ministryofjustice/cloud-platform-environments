terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam = var.team_name
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam = var.team_name
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
  default_tags {
    tags = {
      GithubTeam = var.team_name
    }
  }
}

locals {
  dev_namespaces = toset([var.namespace, "offender-management-test", "offender-management-test2"])
}
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

