module "ecr-repo-prison-visits-tests" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  repo_name           = "prison-visits-integration-tests"
  oidc_providers      = ["circleci"]
  github_repositories = ["prison-visits-integration-tests"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "prison-visits-booking"
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr-repo-prison-visits-tests" {
  metadata {
    name      = "ecr-repo-prison-visits-tests"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr-repo-prison-visits-tests.repo_arn
    repo_url = module.ecr-repo-prison-visits-tests.repo_url
  }
}
