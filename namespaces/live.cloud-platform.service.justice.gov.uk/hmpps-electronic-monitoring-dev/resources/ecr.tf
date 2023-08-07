module "ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"
  team_name = var.team_name
  repo_name = "${var.namespace}-architecture-docs-ecr"

  oidc_providers = ["circleci"]

  github_repositories = ["em-architecture-docs"]

  namespace = var.namespace

  providers = {
    aws = aws.london
  }

}
