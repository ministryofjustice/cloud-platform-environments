module "secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"

  eks_cluster_name = var.eks_cluster_name

  secrets = {
    "cica-review-documents" = {
      description             = "CICA Review Case Documents secrets"
      recovery_window_in_days = 7
      k8s_secret_name         = "cica-case-review-documents-secrets"
    },

    # basic-auth is temporary for redacted demo purposes only
    "basic-auth" = {
      description             = "Temporary basic auth for CICA ingress"
      recovery_window_in_days = 7
      k8s_secret_name         = "basic-auth"
    }
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
