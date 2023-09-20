module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"
  oidc_providers = ["circleci"]
  github_repositories = [var.github_repo_name]
  namespace = var.namespace

  providers = {
    aws = aws.london_without_default_tags
  }
}
