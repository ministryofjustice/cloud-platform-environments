terraform {
  backend "s3" {
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
