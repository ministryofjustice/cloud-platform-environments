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
      # Must match a GitHub team actually registered via a RoleBinding in
      # 01-rbac.yaml for this namespace (octo-data-architecture-leads),
      # otherwise the Cloud Platform AWS console's team-filter service
      # strips the team out of the user's session tags entirely, causing
      # "DescribeSecret access" errors even for team members.
      GithubTeam    = "octo-data-architecture-leads"
      slack-channel = var.slack_channel
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
