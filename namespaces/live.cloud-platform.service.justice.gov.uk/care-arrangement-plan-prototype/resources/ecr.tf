module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  repo_name = "${var.namespace}-ecr"

  oidc_providers      = [var.oidc_name]
  github_repositories = [var.namespace]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr_credentials.repo_arn
    repo_url = module.ecr_credentials.repo_url
  }
}
