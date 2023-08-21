module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name = var.team_name
  repo_name = "fb-editor-web"

  oidc_providers = ["circleci"]

  github_repositories = ["fb-editor"]

  namespace = var.namespace
}
