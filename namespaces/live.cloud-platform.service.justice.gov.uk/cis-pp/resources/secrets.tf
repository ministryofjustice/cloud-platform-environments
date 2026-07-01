module "cis_pp_cognito_test_user_secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "cis-pp-cognito-test-user-secret" = {
      description             = "CIS PP Cognito Test User Secret" # required
      recovery_window_in_days = 7                # required
      k8s_secret_name         = "cis-pp-cognito-test-user-secret" # the name of the secret in k8s
    },
    "slack-webhook-url" = {
      description             = "Slack webhook URL for CIS PP AlertManager alerts (#laa-cis-pp-alerts)"
      recovery_window_in_days = 7
      k8s_secret_name         = "cis-pp-slack-webhook"
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