module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.6"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "secret_key_base" = {
      description             = "Secret Key Base Encoder for Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "secret-key-base"
    },
    "api_auth_secret_maat_adapter" = {
      description             = "MAAT Adapter API Auth Secret for Dev",
      recovery_window_in_days = 7
      k8s_secret_name         = "api-auth-secret-maat-adapter"
    }
  }
}