module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repository configuration
  repo_name = "${var.namespace}-ecr"

  deletion_protection = false

  # OpenID Connect configuration
  oidc_providers      = ["github"]
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
