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
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

provider "github" {
  # token = var.github_token
  owner = var.github_owner
  app_auth {
    id              = var.cloud_platform_concourse_bot_app_id
    installation_id = var.cloud_platform_concourse_bot_installation_id
    pem_file        = var.cloud_platform_concourse_bot_pem_file
  }
}