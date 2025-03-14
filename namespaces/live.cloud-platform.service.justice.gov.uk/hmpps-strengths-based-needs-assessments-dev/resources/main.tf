terraform {
  backend "s3" {
  }
}

data "terraform_remote_state" "coordinator_state" {
  backend = "s3"

  config = {
    region = "eu-west-1"
    bucket = "cloud-platform-terraform-state"
    key    = "cloud-platform-environments/live-1.cloud-platform.service.justice.gov.uk/hmpps-assess-risks-and-needs-integrations-dev/terraform.tfstate"
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

provider "kubernetes" {}
