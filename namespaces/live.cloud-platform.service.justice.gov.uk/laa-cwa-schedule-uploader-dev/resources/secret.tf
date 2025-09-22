module "secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=version" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "cwa-schedule-uploader-api" = {
      description             = "CWA Schedule Uploader API Secrets" # required
      recovery_window_in_days = 7                # required
      k8s_secret_name         = "cwa-schedule-uploader-api" # the name of the secret in k8s
    },
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
