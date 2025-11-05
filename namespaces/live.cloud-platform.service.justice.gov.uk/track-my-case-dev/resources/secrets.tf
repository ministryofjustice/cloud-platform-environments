module "secrets_manager_multiple_secrets" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "tmc-ui-oauth-clientid-aws-secret" = {
      description             = "TMC ui oauth client id",
      recovery_window_in_days = 7
      k8s_secret_name         = "tmc-ui-oauth-clientid"
    },
    "tmc-ui-oauth-clientsecret-aws-secret" = {
      description             = "TMC ui oauth clientId secret",
      recovery_window_in_days = 7
      k8s_secret_name         = "tmc-ui-oauth-clientsecret"
    },
    "tmc-ui-oauth-tenantid-aws-secret" = {
      description             = "TMC ui oauth tenant id",
      recovery_window_in_days = 7
      k8s_secret_name         = "tmc-ui-oauth-tenantid"
    },
    "tmc-ui-oauth-apiscope-aws-secret" = {
      description             = "TMC ui oauth api scope",
      recovery_window_in_days = 7
      k8s_secret_name         = "tmc-ui-oauth-apiscope"
    },

    "tmc-ui-oauth-tokenendpoint-aws-secret" = {
      description             = "TMC ui oauth token endpoint",
      recovery_window_in_days = 7
      k8s_secret_name         = "tmc-ui-oauth-tokenendpoint"
    },
  }
}