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
    "${var.environment}-caab-api-secrets" = {
      description             = "Secrets for CAAB API",
      recovery_window_in_days = 7,
      k8s_secret_name         = "${var.environment}-caab-api-secrets"
    },
    "${var.environment}-caab-assessment-api-secrets" = {
      description             = "Secrets for CAAB Assessment API",
      recovery_window_in_days = 7,
      k8s_secret_name         = "${var.environment}-caab-assessment-api-secrets"
    },
    "${var.environment}-caab-ebs-api-secrets" = {
      description             = "Secrets for CAAB EBS API",
      recovery_window_in_days = 7,
      k8s_secret_name         = "${var.environment}-caab-ebs-api-secrets"
    },
    "${var.environment}-caab-soa-api-secrets" = {
      description             = "Secrets for CAAB SOA API",
      recovery_window_in_days = 7,
      k8s_secret_name         = "${var.environment}-caab-soa-api-secrets"
    },
    "${var.environment}-caab-ui-secrets" = {
      description             = "Secrets for CAAB UI",
      recovery_window_in_days = 7,
      k8s_secret_name         = "${var.environment}-caab-ui-secrets"
    }
    "${var.environment}-caab-datasource-secrets" = {
      description             = "Secrets for CAAB Datasource",
      recovery_window_in_days = 7,
      k8s_secret_name         = "${var.environment}-caab-datasource-secrets"
    }
  }
}