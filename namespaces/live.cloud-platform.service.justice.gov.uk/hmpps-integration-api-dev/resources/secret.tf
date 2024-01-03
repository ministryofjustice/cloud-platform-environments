module "secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.0" 
  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "integration-api-slack-webhook-url" = {
      description             = "Slack webhook url for Integration API gateway api alerts",
      recovery_window_in_days = 7,
      k8s_secret_name         = "slack-webhook-url"
    },
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  GithubTeam             = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
   providers = {
    aws = aws.london_without_default_tags
  }
}