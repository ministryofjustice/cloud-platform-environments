module "ecr_repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"
}

resource "kubernetes_secret" "ecr_repo" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr_repo.repo_url
    access_key_id     = module.ecr_repo.access_key_id
    secret_access_key = module.ecr_repo.secret_access_key
  }
}
