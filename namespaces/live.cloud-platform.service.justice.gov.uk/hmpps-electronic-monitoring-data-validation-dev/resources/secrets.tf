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
    "dns_resolver_domain" = {
      description             = "DNS Resolver Domain",
      recovery_window_in_days = 0
      k8s_secret_name         = "dns-resolver-domain"
    },
    "dns_resolver_ip" = {
      description             = "DNS Resolver IP",
      recovery_window_in_days = 0
      k8s_secret_name         = "dns-resolver-ip"
    },
  }
}
