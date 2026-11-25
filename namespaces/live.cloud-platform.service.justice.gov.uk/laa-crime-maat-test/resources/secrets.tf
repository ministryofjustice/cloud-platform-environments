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

  # Each secret is a JSON object whose flat top-level keys are env var names
  # (e.g. MAAT_CD_AUTH_CLIENT_SECRET), so each key becomes a key in the k8s Secret
  # and pods can consume it with envFrom/secretRef. Values are set in AWS, not here.
  secrets = {
    "maat-functional-tests-dev" = {
      description             = "Functional test suite secrets (Cognito clients, mock JWT, HMCTS API key, Slack webhook, MAAT test user passwords) for the dev target",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-functional-tests-dev" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "maat-functional-tests-tst" = {
      description             = "Functional test suite secrets (Cognito clients, mock JWT, HMCTS API key, Slack webhook, MAAT test user passwords) for the tst target",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-functional-tests-tst" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "maat-functional-tests-uat" = {
      description             = "Functional test suite secrets (Cognito clients, mock JWT, HMCTS API key, Slack webhook, MAAT test user passwords) for the uat target",
      recovery_window_in_days = 7
      k8s_secret_name         = "maat-functional-tests-uat" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
  }
}
