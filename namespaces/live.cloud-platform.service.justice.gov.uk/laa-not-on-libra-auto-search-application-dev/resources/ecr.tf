module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  # REQUIRED: Repository configuration
  team_name = var.team_name
  repo_name = var.namespace
  namespace = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["circleci"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories = ["laa-nolasa"]
}