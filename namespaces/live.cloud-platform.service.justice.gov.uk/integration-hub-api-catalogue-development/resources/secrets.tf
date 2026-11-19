module "api_catalogue_django_secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"

  eks_cluster_name       = var.eks_cluster_name
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  secrets = {
    "api-catalogue-django" = {
      description             = "Django secret key for API catalogue"
      recovery_window_in_days = 7
      k8s_secret_name         = "api-catalogue-django"
    }
  }
}
