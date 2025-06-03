module "ecr-test" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  repo_name           = "probation-teams"
  oidc_providers      = ["circleci"]
  github_repositories = ["probation-teams"]

  # Tags
  business_unit          = var.business_unit
  application            = "probation-teams"
  is_production          = var.is_production
  team_name              = "probation-teams"
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr-test" {
  metadata {
    name      = "ecr-test-probation-teams"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr-test.repo_arn
    repo_url = module.ecr-test.repo_url
  }
}