terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      # see https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/accessing-the-cloud-console.html
      GithubTeam = var.team_name
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      # see https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/accessing-the-cloud-console.html
      GithubTeam = var.team_name
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
      # see https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/accessing-the-cloud-console.html
      GithubTeam = var.team_name
    }
  }
}
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

