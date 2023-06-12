module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  oidc_providers      = ["github"]
  github_repositories = [var.namespace]
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_url = module.ecr-repo.repo_url
    repo_arn = module.ecr-repo.repo_arn
  }
}
