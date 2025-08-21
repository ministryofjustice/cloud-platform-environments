module "secrets_manager_multiple_secrets" {
  # source                 = "../" # use the latest release
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  secrets = {
    "pact-broker-basic-auth-username" = {
      description             = "Username required to authenticate with the Pact Broker.",
      recovery_window_in_days = 0
      k8s_secret_name         = "PACT_BROKER_BASIC_AUTH_USERNAME" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
    "pact-broker-basic-auth-password" = {
      description             = "Password associated with the username for authentication with the Pact Broker",
      recovery_window_in_days = 0
      k8s_secret_name         = "PACT_BROKER_BASIC_AUTH_PASSWORD" # The name of the secret in k8s and must only contain lowercase alphanumeric characters, dots and dashes
    },
  }
}