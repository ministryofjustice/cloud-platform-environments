module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repository configuration
  repo_name = "${var.team_name}/${var.namespace}"

  # ✅ This flag tells the pipeline it's safe to destroy this duplicate resource
  deletion_protection = false

  # OpenID Connect configuration
  # Commented out to completely stop the 409 GitHub Variable collisions
  # oidc_providers      = ["github"]
  # github_repositories = ["justice-redact-frontend", "justice-redact-backend"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name 
  namespace              = var.namespace 
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  enable_irsa = true
}