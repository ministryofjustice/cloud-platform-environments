module "cis_prd_entra_prod_external_client_secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "cis-prd-entra-prod-external-client-secret" = {
      description             = "CIS PRD Entra Prod External Client Secret" # required
      recovery_window_in_days = 7                                          # required
      k8s_secret_name         = "cis-prd-entra-prod-external-client-secret" # the name of the secret in k8s
    },
    "cis-prd-entra-prod-external-client-id" = {
      description             = "CIS PRD Entra Prod External Client ID" # required
      recovery_window_in_days = 7                                      # required
      k8s_secret_name         = "cis-prd-entra-prod-external-client-id" # the name of the secret in k8s
    },
    "cis-prd-entra-prod-external-tenant-id" = {
      description             = "CIS PRD Entra Prod External Tenant ID" # required
      recovery_window_in_days = 7                                      # required
      k8s_secret_name         = "cis-prd-entra-prod-external-tenant-id" # the name of the secret in k8s
    },
    "cis-prd-cognito-test-user-secret" = {
      description             = "CIS PRD Cognito Test User Secret" # required
      recovery_window_in_days = 7                                 # required
      k8s_secret_name         = "cis-prd-cognito-test-user-secret" # the name of the secret in k8s
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