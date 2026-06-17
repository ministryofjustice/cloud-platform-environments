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
    "entra-oauth2-proxy" = {
      description             = "Entra OAuth2 Details",
      recovery_window_in_days = 0
      k8s_secret_name         = "entra-oauth2-proxy"
    },
    "secret-key" = {
      description             = "Session secret",
      recovery_window_in_days = 0
      k8s_secret_name         = "secret-key"
    },
  }
}

resource "aws_secretsmanager_secret" "dns_resolver" {
  name = "dns-resolver"
  description = "DNS Resolver Secret"
  recovery_window_in_days = 0

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

data "aws_secretsmanager_secret_version" "dns_resolver" {
  secret_id = data.aws_secretsmanager_secret.dns_resolver.id
}

data "aws_secretsmanager_secret" "dns_resolver" {
  name = aws_secretsmanager_secret.dns_resolver.name

  depends_on = [
    aws_secretsmanager_secret.dns_resolver
  ]
}
