module "secrets" {
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
    "laa-apply-for-legalaid-secrets" = {
      description             = "laa-apply-for-legalaid-uat secrets",
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-apply-for-legalaid-secrets"
    },
    "staging-ccms-connection" = {
      description             = "Allow connection to CCMS Staging from a Civil Apply UAT branch",
      recovery_window_in_days = 7
      k8s_secret_name         = "staging-ccms-connection"
    },
    "uat-ccms-connection" = {
      description             = "Allow connection to CCMS UAT/Test from a Civil Apply UAT branch",
      recovery_window_in_days = 7
      k8s_secret_name         = "uat-ccms-connection"
    },
    "dev-ccms-connection" = {
      description             = "Allow connection to CCMS Dev from a Civil Apply UAT branch",
      recovery_window_in_days = 7
      k8s_secret_name         = "dev-ccms-connection"
    },
    "staging-portal-connection" = {
      description             = "Allow connection to Staging Portal from a Civil Apply UAT branch",
      recovery_window_in_days = 7
      k8s_secret_name         = "staging-portal-connection"
    },
    "uat-lfa-connection" = {
      description             = "Allow connection to a Legal Framework API UAT branch from a Civil Apply UAT branch",
      recovery_window_in_days = 7
      k8s_secret_name         = "uat-lfa-connection"
    },
  }
}
