terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
    default_tags {
    tags = {
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
      GithubTeam = "cica"
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
    default_tags {
    tags = {
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
      GithubTeam = "cica"
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
    default_tags {
    tags = {
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
      GithubTeam = "cica"
    }
  }
}

provider "kubernetes" {}

provider "helm" {
  kubernetes {
  }
}
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

