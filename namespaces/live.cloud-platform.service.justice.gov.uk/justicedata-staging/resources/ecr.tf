module "ecr-repo" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"
  team_name           = var.team_name
  repo_name           = "${var.namespace}-ecr"
  github_repositories = ["justice-data"]
  oidc_providers      = ["github"]
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_url  = module.ecr-repo.repo_url
  }
}
