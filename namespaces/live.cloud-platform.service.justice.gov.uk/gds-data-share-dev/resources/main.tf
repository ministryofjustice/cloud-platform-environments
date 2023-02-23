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

