module "ecr_cwa_submissions" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  repo_name     = var.namespace
  github_repositories = ["cwa-submissions-api"]

  # Tags
  team_name              = var.team_name
  namespace              = var.namespace
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "ecr_csv_converter" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  repo_name     = var.namespace
  repo_suffix   = "-csv"  # ✅ This differentiates the repo name

  github_repositories = ["cwa-submissions-api"]

  # Tags
  team_name              = var.team_name
  namespace              = var.namespace
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
