module "secrets_manager_multiple_secrets" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.2"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "cica-web-aws-secrets" = {
      description             = "Cica web secrets PROD",
      recovery_window_in_days = 7
      k8s_secret_name         = "cica-web-secrets"
    },
    "data-capture-service-aws-secrets" = {
      description             = "Data capture service secrets PROD",
      recovery_window_in_days = 7
      k8s_secret_name         = "data-capture-service-secrets"
    },
    "shared-aws-secrets" = {
      description             = "Shared secrets PROD",
      recovery_window_in_days = 7
      k8s_secret_name         = "shared-secrets"
    },
  }
}