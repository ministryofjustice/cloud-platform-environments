terraform {
  backend "s3" {
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
      GithubTeam = "hmpps-move-and-improve"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
