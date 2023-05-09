module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.4"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  github_repositories = ["apply-for-compensation-prototype"]

  github_actions_secret_ecr_name       = var.github_actions_secret_ecr_name
  github_actions_secret_ecr_url        = var.github_actions_secret_ecr_url
  github_actions_secret_ecr_access_key = var.github_actions_secret_ecr_access_key
  github_actions_secret_ecr_secret_key = var.github_actions_secret_ecr_secret_key

}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr-repo.repo_url
    access_key_id     = module.ecr-repo.access_key_id
    secret_access_key = module.ecr-repo.secret_access_key
    repo_arn          = module.ecr-repo.repo_arn
  }
}
