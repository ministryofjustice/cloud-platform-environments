module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  # Holds the GitHub App private key, GitHub App client secret and Django session secret
  # as JSON keys, which are synced to a single Kubernetes secret.
  secrets = {
    "ai-enablement-wrapped-prod-app" = {
      description             = "ministryofjustice Wrapped ${var.environment} application secrets"
      recovery_window_in_days = 7
      k8s_secret_name         = "ai-enablement-wrapped-prod-app"
    }
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
