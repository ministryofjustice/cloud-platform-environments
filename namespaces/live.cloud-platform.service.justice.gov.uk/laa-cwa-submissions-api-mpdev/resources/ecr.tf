module "ecr_cwa_submissions" {
  source  = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"
  repo_name           = "cwa-submissions-api"
  oidc_providers      = ["github"]
  github_repositories = ["cwa-submissions-api"]

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "ecr_csv_converter" {
  source  = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"
  repo_name           = "csv-converter"
  oidc_providers      = ["github"]
  github_repositories = ["cwa-submissions-api"]

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
