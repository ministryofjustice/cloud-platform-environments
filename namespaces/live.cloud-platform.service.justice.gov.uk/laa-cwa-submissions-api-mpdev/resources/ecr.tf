module "ecr_cwa_submissions" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name             = var.namespace
  oidc_providers        = ["github"]
  github_repositories   = ["cwa-submissions-api"]
  github_actions_prefix = "SUBMISSIONS"  

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "ecr_csv_converter" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name             = var.namespace
  oidc_providers        = ["github"]
  github_repositories   = ["cwa-submissions-api"]
  github_actions_prefix = "CONVERTER"    

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

