module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  repo_name = "${var.namespace}-ecr"

  oidc_providers      = ["github"]
  github_repositories = ["cloud-platform-cluster-populator"]

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}