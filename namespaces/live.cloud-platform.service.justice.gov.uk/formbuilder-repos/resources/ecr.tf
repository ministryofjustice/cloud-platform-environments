module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  oidc_providers = ["circleci"]

  github_repositories = ["fb-deploy"]

  namespace = var.namespace
}
