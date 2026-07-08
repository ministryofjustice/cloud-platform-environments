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
    "app-secrets" = {
      description             = "[app-secrets] App configuration secrets for PDA-r1"
      recovery_window_in_days = 7
      k8s_secret_name         = "app-secrets"
    }
    "pda-r1-configuration" = {
      description             = "[pda-r1-configuration] Configuration secrets for PDA-r1"
      recovery_window_in_days = 7
      k8s_secret_name         = "pda-r1-configuration"
    }
    "pda-r1-novation-data" = {
      description             = "[pda-r1-novation-data] Novation data secrets for PDA-r1"
      recovery_window_in_days = 7
      k8s_secret_name         = "pda-r1-novation-data"
    }
    "pda-r2-configuration" = {
      description             = "[pda-r2-configuration] Configuration secrets for PDA-r2"
      recovery_window_in_days = 7
      k8s_secret_name         = "pda-r2-configuration"
    }
  }
}
