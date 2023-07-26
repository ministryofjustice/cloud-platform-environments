module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  oidc_providers      = ["github"]
  github_repositories = ["hmpps-mercury-data-monorepo"]
}

resource "kubernetes_secret" "manage_intelligence_ecr" {
  metadata {
    name      = "manage-intelligence-ecr-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.manage_intelligence_ecr.access_key_id
    secret_access_key = module.manage_intelligence_ecr.secret_access_key
    repo_arn          = module.manage_intelligence_ecr.repo_arn
    repo_url          = module.manage_intelligence_ecr.repo_url
  }
}