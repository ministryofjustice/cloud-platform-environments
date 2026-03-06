terraform {
  backend "s3" {
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam    = var.team_name
      slack-channel = var.slack_channel
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
