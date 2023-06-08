module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"

  team_name = var.team_name
  repo_name = "oidc-test"

  github_repositories = ["cloud-platform-ecr-oidc-test"]
  oidc_providers      = ["circleci"]
  namespace           = var.namespace
}
