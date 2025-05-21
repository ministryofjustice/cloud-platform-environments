module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "ccms-pda-secrets" = {
      description             = "Secrets for ccms pda",
      recovery_window_in_days = 7,
      k8s_secret_name         = "ccms-pda-secrets"
    },
    "ccms-assess-service-adaptor-secrets" = {
        description             = "Secrets for ccms assess service adaptor",
        recovery_window_in_days = 7,
        k8s_secret_name         = "ccms-assess-service-adaptor-secrets"
    },
    "ccms-pui-secrets" = {
        description             = "Secrets for ccms pui",
        recovery_window_in_days = 7,
        k8s_secret_name         = "ccms-pui-secrets"
    },
    "ccms-connector-secrets" = {
        description             = "Secrets for ccms connector",
        recovery_window_in_days = 7,
        k8s_secret_name         = "ccms-connector-secrets"
    },
    "ccms-edrms-web-service-secrets" = {
        description             = "Secrets for ccms edrms api",
        recovery_window_in_days = 7,
        k8s_secret_name         = "ccms-edrms-web-service-secrets"
    }
    "ccms-opa-hub-secrets" = {
        description             = "Secrets for ccms opa hub",
        recovery_window_in_days = 7,
        k8s_secret_name         = "ccms-opa-hub-secrets"
    }
  }
}
