module "secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "integration-api-slack-webhook-url" = {
      description             = "Slack webhook url for Integration API gateway api alerts",
      recovery_window_in_days = 7,
      k8s_secret_name         = "slack-webhook-url"
    },
    "integration-api-event-mapps-filter-list" = {
      description             = "MAPPS event filter list",
      recovery_window_in_days = 7,
      k8s_secret_name         = "mapps-filter-list"
    },
    "integration-api-event-kilco-filter-list" = {
      description             = "Kilco event filter list",
      recovery_window_in_days = 7,
      k8s_secret_name         = "kilco-filter-list"
    },
    "integration-api-event-pnd-filter-list" = {
      description             = "PND event filter list",
      recovery_window_in_days = 7,
      k8s_secret_name         = "pnd-filter-list"
    },
    "integration-api-event-plp-filter-list" = {
      description             = "PLP event filter list",
      recovery_window_in_days = 7,
      k8s_secret_name         = "plp-filter-list"
    },
    "integration-api-event-bmadley-filter-list" = {
      description             = "bmadley event filter list",
      recovery_window_in_days = 7,
      k8s_secret_name         = "bmadley-filter-list"
    },
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

data "aws_secretsmanager_secret" "slack_webhook_url" {
  # NB secret name is generated by secret module and could be change. Current version 3.0.0 does not output the name of the secret.
  name = "live-hmpps-integration-api-dev-b3ca37577c87fc7b"
}

data "aws_secretsmanager_secret_version" "slack_webhook_url" {
  secret_id = data.aws_secretsmanager_secret.slack_webhook_url.id
}