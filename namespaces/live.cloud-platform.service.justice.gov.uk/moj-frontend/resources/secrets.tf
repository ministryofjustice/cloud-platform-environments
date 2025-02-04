module "secrets_manager_multiple_secrets" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "github-api-url" = {
      description             = "GitHub API URL",
      recovery_window_in_days = 7,
      k8s_secret_name         = "github-api-url"
    },

    "github-token" = {
      description             = "GitHub API token",
      recovery_window_in_days = 7,
      k8s_secret_name         = "github-token"
    },

    "github-repo-owner" = {
      description             = "GitHub repository owner",
      recovery_window_in_days = 7,
      k8s_secret_name         = "github-repo-owner"
    },

    "github-repo-name" = {
      description             = "GitHub repository name",
      recovery_window_in_days = 7,
      k8s_secret_name         = "github-repo-name"
    },

    "notify-pr-template" = {
      description             = "Notification PR template",
      recovery_window_in_days = 7,
      k8s_secret_name         = "notify-pr-template"
    },

    "notify-submission-template" = {
      description             = "Notification submission template",
      recovery_window_in_days = 7,
      k8s_secret_name         = "notify-submission-template"
    },

    "notify-email" = {
      description             = "Notification email",
      recovery_window_in_days = 7,
      k8s_secret_name         = "notify-email"
    },

    "notify-token" = {
      description             = "Notification token",
      recovery_window_in_days = 7,
      k8s_secret_name         = "notify-token"
    }
  }
}