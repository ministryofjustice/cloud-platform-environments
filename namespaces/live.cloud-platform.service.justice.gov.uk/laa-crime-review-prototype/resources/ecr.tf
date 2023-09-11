module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  oidc_providers      = ["github"]
  github_repositories = [var.namespace]
}
