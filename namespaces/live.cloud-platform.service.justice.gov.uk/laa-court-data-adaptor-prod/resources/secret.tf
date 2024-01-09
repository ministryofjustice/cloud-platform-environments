module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.2"
  team_name              = "laa-crime-apps-team"
  application            = var.application
  business_unit          = "LAA"
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "maat_api_oauth_client_credentials" = {
      description             = "MAAT API oauth client id and secret",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-api-oauth-client-credentials"
    },
  }
}