terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam = var.team_name
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

