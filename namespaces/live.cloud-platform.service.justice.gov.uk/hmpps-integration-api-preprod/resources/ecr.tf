module "ecr_credentials" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"
  team_name              = var.team_name
  repo_name              = "${var.namespace}-ecr"
  oidc_providers         = ["circleci"]
  github_repositories    = [var.github_repo_name]
  namespace              = var.namespace
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  business_unit          = var.business_unit
  application            = var.application

  providers = {
    aws = aws.london_without_default_tags
  }
}
