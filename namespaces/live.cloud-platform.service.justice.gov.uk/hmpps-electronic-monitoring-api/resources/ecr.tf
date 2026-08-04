module "pipelines-ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  # Repository configuration
  repo_name = "${var.namespace}-pipelines"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = [var.application_repository]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  github_environments    = [var.environment]
  github_actions_prefix  = "pipelines"

  enable_irsa = true
}
