terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      GithubTeam = "prisoner-content-hub-developers"
    }
  }
}

# To be use in case the resources need to be created in London
provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      GithubTeam = "prisoner-content-hub-developers"
    }
  }
}

# To be use in case the resources need to be created in Ireland
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
      GithubTeam = "prisoner-content-hub-developers"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

