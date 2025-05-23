module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "slack-webhook" = {
      description             = "Contains the slack webhook url to send notifications",
      recovery_window_in_days = 7,
      k8s_secret_name         = "probation-in-court-preprod-slack-webhook"
    },
    "applicationinsights" = {
      description             = "Contains the application insights connection string for preprod",
      recovery_window_in_days = 7,
      k8s_secret_name         = "applicationinsights-connection-string"
    },
    "case-tracking-pre-pilot-users" = {
      description             = "Pilot Users for Case Tracking",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "case-tracking-pre-pilot-users" # The name of the secret in k8s
    },
    "liverpool-pre-pilot-users" = {
      description             = "Liverpool pre pilot users",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "liverpool-pre-pilot-users" # The name of the secret in k8s
    },
    "performance-test-data-user-credentials" = {
      description             = "Performance test user credentials",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "performance-test-data-user-credentials" # The name of the secret in k8s
    }
  }
}