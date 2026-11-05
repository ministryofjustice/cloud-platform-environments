module "ppud_frontend_ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  repo_name           = "${var.namespace}-frontend"
  deletion_protection = true
  oidc_providers      = []
  github_repositories = []
  github_environments = []

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "ppud_backend_ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  repo_name           = "${var.namespace}-backend"
  deletion_protection = true
  oidc_providers      = []
  github_repositories = []
  github_environments = []

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
