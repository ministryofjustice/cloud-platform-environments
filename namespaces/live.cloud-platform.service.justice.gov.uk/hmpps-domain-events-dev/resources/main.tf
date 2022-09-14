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

# To be used for granting access to the probation-integration GitHub team
provider "aws" {
  alias  = "probation-integration"
  region = "eu-west-2"
  tags = {
    GithubTeam = "probation-integration"
  }
}

provider "github" {
  owner = "ministryofjustice"
  token = var.github_token
}
