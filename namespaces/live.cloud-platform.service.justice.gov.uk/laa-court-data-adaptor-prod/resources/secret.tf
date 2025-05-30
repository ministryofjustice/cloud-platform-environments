module "secrets_manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
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
    "court-data-adaptor-alert-webhook-prod" = {
      description             = "Court Data Adaptor Slack Webhook",
      recovery_window_in_days = 7,
      k8s_secret_name         = "court-data-adaptor-alert-webhook-prod"
    },
    "aws-secrets" = {
      description             = "laa-court-data-adaptor-prod aws-secrets",
      recovery_window_in_days = 7
      k8s_secret_name         = "aws-secrets"
    },
  }
}
