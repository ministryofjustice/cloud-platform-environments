# generated by https://github.com/ministryofjustice/money-to-prisoners-deploy
terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      GithubTeam = "prisoner-money"
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      GithubTeam = "prisoner-money"
    }
  }
}
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

