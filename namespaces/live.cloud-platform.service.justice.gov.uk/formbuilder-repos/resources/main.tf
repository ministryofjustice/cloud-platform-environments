terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam = "form-builder"
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam = "form-builder"
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
  default_tags {
    tags = {
      GithubTeam = "form-builder"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

