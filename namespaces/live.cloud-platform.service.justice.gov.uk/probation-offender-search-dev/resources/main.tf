terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
}

# To be use in case the resources need to be created in London
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

# To be use in case the resources need to be created in Ireland
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

provider "github" {
  owner = "ministryofjustice"
  token = var.github_token
}

provider "random" {
  version = "3.3.2" # Pinned version, due to bcrypt bug in 3.4.0+. See https://github.com/hashicorp/terraform-provider-random/issues/307
}