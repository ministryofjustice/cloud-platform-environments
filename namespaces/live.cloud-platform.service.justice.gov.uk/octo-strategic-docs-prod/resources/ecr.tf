module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  repo_name = "${var.namespace}-ecr"

  # OpenID Connect configuration - creates ECR_ROLE_TO_ASSUME/ECR_REGISTRY_URL
  # secrets and ECR_REGION/ECR_REPOSITORY variables in the octo-strategic-docs
  # repo for use in the publish workflow. No static AWS keys are created.
  oidc_providers      = ["github"]
  github_repositories = [var.app_repo]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
