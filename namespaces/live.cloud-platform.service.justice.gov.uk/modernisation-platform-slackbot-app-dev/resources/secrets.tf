module "secrets_manager_multiple_secrets" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "github-token" = {
      description             = "a GitHub personal access token for an account that can access the environments repository and retrigger checks. Obtain this from GitHub Settings, Developer settings, Personal access tokens.",
      recovery_window_in_days = 0
      k8s_secret_name         = "github-token" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "github-url" = {
      description             = "the repository URL used by the API for cloning and by the Slack bot for matching posted pull request links. For this project it should be `https://github.com/ministryofjustice/modernisation-platform-environments.git`.",
      recovery_window_in_days = 0
      k8s_secret_name         = "github-url" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "github-user" = {
      description             = "the GitHub username associated with `GITHUB_TOKEN`. Obtain this from your GitHub account profile.",
      recovery_window_in_days = 0
      k8s_secret_name         = "github-user" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "slack-bot-token" = {
      description             = "the bot user OAuth token for the Slack app. Obtain this from the Slack app configuration under OAuth & Permissions.",
      recovery_window_in_days = 0
      k8s_secret_name         = "slack-bot-token" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "slack-signing-secret" = {
      description             = "the signing secret for the Slack app. Obtain this from the Slack app configuration under Basic Information.",
      recovery_window_in_days = 0
      k8s_secret_name         = "slack-signing-secret" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "slack-app-token" = {
      description             = "the app-level token used for Socket Mode. Obtain this from the Slack app configuration under Basic Information, App-Level Tokens.",
      recovery_window_in_days = 0
      k8s_secret_name         = "slack-app-token" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    }
  }
}
