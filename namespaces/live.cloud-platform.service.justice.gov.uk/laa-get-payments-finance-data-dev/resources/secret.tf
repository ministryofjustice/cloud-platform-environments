
module "secrets_manager" {
  #   source = "../"
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
    "gpfd-test-secret-01" = {
      description             = "gpfd secrets",   # Required
      recovery_window_in_days = 7,                    # Required
      k8s_secret_name         = "gpfd-test-secret-01" # The name of the secret in k8s
    },
    "gpfd-service-alert-webhook-dev" = {
      description             = "[gpfd-service-alert-webhook-dev] Slack webhook"
      recovery_window_in_days = 7
      k8s_secret_name         = "gpfd-service-alert-webhook-dev"
    }
  }
}
