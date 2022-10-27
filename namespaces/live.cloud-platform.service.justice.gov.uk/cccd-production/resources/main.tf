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
  default_tags {
    tags = {
      GithubTeam = "laa-claim-for-payment"
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}
