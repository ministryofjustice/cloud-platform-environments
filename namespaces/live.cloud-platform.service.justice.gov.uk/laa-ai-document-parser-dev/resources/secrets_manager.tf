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
    "laa-ai-document-parser-api-dev" = {
      description             = "LAA AI Document Parser API dev secrets",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-ai-document-parser-api-secrets" 
    },
    "laa-ai-document-parser-ui-dev" = {
      description             = "LAA AI Document Parser UI dev secrets",
      recovery_window_in_days = 7,
      k8s_secret_name         = "laa-ai-document-parser-ui-secrets"
    },
  }
}
