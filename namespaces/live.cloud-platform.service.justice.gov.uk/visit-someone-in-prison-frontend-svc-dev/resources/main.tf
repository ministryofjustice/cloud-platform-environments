terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
        GithubTeam = "hmpps-prison-visits-booking-devs"
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
        GithubTeam = "hmpps-prison-visits-booking-devs"
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
        GithubTeam = "hmpps-prison-visits-booking-devs"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

