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
    "caab-api-secrets" = {
      description             = "Secrets for CAAB API",
      recovery_window_in_days = 7,
      k8s_secret_name         = "caab-api-auth-secrets"
    },
    "caab-assessment-api-secrets" = {
      description             = "Secrets for CAAB Assessment API",
      recovery_window_in_days = 7,
      k8s_secret_name         = "caab-assessment-api-auth-secrets"
    },
    "caab-ebs-api-secrets" = {
      description             = "Secrets for CAAB EBS API",
      recovery_window_in_days = 7,
      k8s_secret_name         = "caab-ebs-api-auth-secrets"
    },
    "caab-soa-api-secrets" = {
      description             = "Secrets for CAAB SOA API",
      recovery_window_in_days = 7,
      k8s_secret_name         = "caab-soa-api-auth-secrets"
    },
    "caab-ui-secrets" = {
      description             = "Secrets for CAAB UI",
      recovery_window_in_days = 7,
      k8s_secret_name         = "caab-ui-secrets"
    },
    "caab-soa-gateway-secrets" = {
      description             = "Secrets for CAAB SOA Gateway",
      recovery_window_in_days = 7,
      k8s_secret_name         = "caab-soa-gateway-secrets"
    }
    "caab-regression-test-secrets" = {
      description             = "Secrets for CAAB Regression Tests",
      recovery_window_in_days = 7,
      k8s_secret_name         = "caab-regression-test-secrets"
    }
  }
}
