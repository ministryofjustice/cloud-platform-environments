terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "london_without_default_tags"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "london_default_github_tag"
  region = "eu-west-2"

  default_tags {
    tags = {
      GithubTeam = var.team_name
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = local.default_tags
  }
}
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

