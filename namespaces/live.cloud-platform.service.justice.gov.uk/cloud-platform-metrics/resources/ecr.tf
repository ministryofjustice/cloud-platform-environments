module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["cloud-platform-metrics"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
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
