module "secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "example" = {
      description             = "CICA Review Case Documents secrets" # required
      recovery_window_in_days = 7                # required
      k8s_secret_name         = "cica-case-review-documents-secrets" # the name of the secret in k8s
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
