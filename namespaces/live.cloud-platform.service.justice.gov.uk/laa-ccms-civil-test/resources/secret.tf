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
    "${var.environment}-saml-metadata-uri" = {
      description             = "The URI for the SAML authentication",              # Required
      recovery_window_in_days = 7,                                                  # Required
      k8s_secret_name         = "${var.environment}-saml-metadata-uri"                                 # The name of the secret in k8s
    },
    "${var.environment}-caab-secrets" = {
      description             = "SOA urls and database credentials for CAAB",       # Required
      recovery_window_in_days = 7,                                                  # Required
      k8s_secret_name         = "${var.environment}-caab-secrets"                                      # The name of the secret in k8s
    },
    "${var.environment}-caab-api-auth-secrets" = {
      description             = "Authentication secrets for CAAB API",              # Required
      recovery_window_in_days = 7,                                                  # Required
      k8s_secret_name         = "${var.environment}-caab-api-auth-secrets"                             # The name of the secret in k8s
    },
    "${var.environment}-caab-assessment-api-auth-secrets" = {
      description             = "Authentication secrets for CAAB Assessment API",   # Required
      recovery_window_in_days = 7,                                                  # Required
      k8s_secret_name         = "${var.environment}-caab-assessment-api-auth-secrets"                  # The name of the secret in k8s
    },
    "${var.environment}-caab-ebs-api-auth-secrets" = {
      description             = "Authentication secrets for CAAB EBS API",          # Required
      recovery_window_in_days = 7,                                                  # Required
      k8s_secret_name         = "${var.environment}-caab-ebs-api-auth-secrets"                         # The name of the secret in k8s
    },
    "${var.environment}-caab-soa-api-auth-secrets" = {
      description             = "Authentication secrets for CAAB SOA API",          # Required
      recovery_window_in_days = 7,                                                  # Required
      k8s_secret_name         = "${var.environment}-caab-soa-api-auth-secrets"                         # The name of the secret in k8s
    },
    "${var.environment}-caab-ui-secrets" = {
      description             = "Secrets for CAAB UI",                              # Required
      recovery_window_in_days = 7,                                                  # Required
      k8s_secret_name         = "${var.environment}-caab-ui-secrets"                                   # The name of the secret in k8s
    },
  }
}
