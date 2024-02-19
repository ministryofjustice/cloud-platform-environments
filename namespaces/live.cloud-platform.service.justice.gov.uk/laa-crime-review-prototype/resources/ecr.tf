module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  namespace              = var.namespace
  application            = var.application
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  business_unit          = var.business_unit
  environment_name       = var.environment

  oidc_providers      = ["github"]
  github_repositories = [var.namespace]
}
