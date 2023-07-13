module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  # REQUIRED: Repository configuration
  team_name = var.team_name
  repo_name = var.namespace
  namespace = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["circleci", "github"]
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr.access_key_id
    secret_access_key = module.ecr.secret_access_key
    repo_arn          = module.ecr.repo_arn
    repo_url          = module.ecr.repo_url
  }
}
