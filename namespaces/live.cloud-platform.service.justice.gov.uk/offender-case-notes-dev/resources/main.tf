terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
