module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.0"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "GITHUB_TOKEN" = {
      description             = "github api token",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "github-token" # The name of the secret in k8s
    },

    "GITHUB_USER" = {
      description             = "github user",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "github-user" # The name of the secret in k8s
    },

    "GITHUB_URL" = {
      description             = "github url",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "github-url" # The name of the secret in k8s
    },

    "SLACK_APP_TOKEN" = {
      description             = "slack app token",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "slack-app-token" # The name of the secret in k8s
    },

    "SLACK_SIGNING_SECRET" = {
      description             = "slack signing secret",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "slack-signing-secret" # The name of the secret in k8s
    },

    "SLACK_BOT_TOKEN" = {
      description             = "slack bot token",   # Required
      recovery_window_in_days = 7,               # Required
      k8s_secret_name         = "slack-bot-token" # The name of the secret in k8s
    },
  }
}
