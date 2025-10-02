module "container_repository" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repo & OIDC
  repo_name           = var.namespace                     # e.g. "reuselibrary-dev"
  oidc_providers      = ["github"]
  github_repositories = ["reuse-library"]
  github_environments = ["dev"]

  # Tags/metadata
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # Optional: allow querying ECR via IRSA from the namespace (read-only)
  # enable_irsa = true
}
