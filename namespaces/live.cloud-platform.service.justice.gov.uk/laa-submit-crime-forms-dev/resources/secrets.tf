module "secrets" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "elasticache_primary_endpoint_address" = {
      description             = "Elasticache primary endpoint address"
      recovery_window_in_days = 7               
      k8s_secret_name         = "elasticache-primary-endpoint-address"
    },
    "elasticache_auth_token" = {
      description             = "Elasticache auth token"
      recovery_window_in_days = 7               
      k8s_secret_name         = "elasticache-auth-token"
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