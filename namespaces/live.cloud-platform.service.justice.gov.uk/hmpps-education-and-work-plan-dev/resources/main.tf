terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
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