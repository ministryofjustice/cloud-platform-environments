terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam = "justice-ai-unit"
      slack-channel = var.slack_channel
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
