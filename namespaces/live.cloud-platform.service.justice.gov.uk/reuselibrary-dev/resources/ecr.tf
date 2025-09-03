module "container_repository" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repo & OIDC
  repo_name           = var.namespace                     # e.g. "reuselibrary-dev"
  oidc_providers      = ["github"]
  github_repositories = ["ministryofjustice/reuse-library"]
  # Optional: scope to a GitHub Environment called "dev"
  # github_environments = ["dev"]

  # Tags/metadata (use your env vars)
  business_unit          = var.business_unit              # e.g. "Platforms"
  application            = var.application                # "Reuse Library"
  is_production          = "false"
  team_name              = var.team_name                  # e.g. "reuse-library"
  namespace              = var.namespace                  # "reuselibrary-dev"
  environment_name       = "dev"
  infrastructure_support = "reuse-library@justice.gov.uk"

  # Optional: allow querying ECR via IRSA from the namespace (read-only)
  # enable_irsa = true
}
