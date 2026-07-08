module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "${var.environment}-ccms-assess-service-adaptor-secrets" = {
        description             = "Secrets for ccms assess service adaptor",
        recovery_window_in_days = 7,
        k8s_secret_name         = "${var.environment}-ccms-assess-service-adaptor-secrets"
    },
    "${var.environment}-ccms-pui-secrets" = {
        description             = "Secrets for ccms pui",
        recovery_window_in_days = 7,
        k8s_secret_name         = "${var.environment}-ccms-pui-secrets"
    },
    "${var.environment}-ccms-pui-internal-secrets" = {
        description             = "Secrets for ccms pui internal",
        recovery_window_in_days = 7,
        k8s_secret_name         = "${var.environment}-ccms-pui-internal-secrets"
    },
    "${var.environment}-ccms-connector-secrets" = {
        description             = "Secrets for ccms connector",
        recovery_window_in_days = 7,
        k8s_secret_name         = "${var.environment}-ccms-connector-secrets"
    },
    "${var.environment}-ccms-opa-hub-secrets" = {
        description             = "Secrets for ccms opa hub",
        recovery_window_in_days = 7,
        k8s_secret_name         = "${var.environment}-ccms-opa-hub-secrets"
    }
  }
}
