module "ecr_repo_frontend" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.1"

  repo_name             = "onboarding-optimisation-frontend"
  github_actions_prefix = "frontend"

  oidc_providers      = ["github"]
  github_repositories = ["onboarding-optimisation"]
  github_environments = ["dev"]

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "ecr_repo_backend" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.1"

  repo_name             = "onboarding-optimisation-backend"
  github_actions_prefix = "backend"

  oidc_providers      = ["github"]
  github_repositories = ["onboarding-optimisation"]
  github_environments = ["dev"]

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
