module "ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.5"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  scan_on_push = "false"

  github_repositories = ["raz-test"]
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-credentials-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials.access_key_id
    secret_access_key = module.ecr_credentials.secret_access_key
    repo_arn          = module.ecr_credentials.repo_arn
    repo_url          = module.ecr_credentials.repo_url
  }
}
