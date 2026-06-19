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
    "dns_resolver_cidr" = {
      description             = "DNS Resolver CIDR",
      recovery_window_in_days = 0
      k8s_secret_name         = "dns-resolver-cidr"
    },
  }
}

data "aws_secretsmanager_secret" "dns_resolver_domain" {
  name = module.secrets_manager_multiple_secrets.secret_names["dns_resolver_domain"]
}

data "aws_secretsmanager_secret_version" "dns_resolver_domain" {
  secret_id = data.aws_secretsmanager_secret.dns_resolver_domain.id
}

data "aws_secretsmanager_secret" "dns_resolver_ip" {
  name = module.secrets_manager_multiple_secrets.secret_names["dns_resolver_ip"]
}

data "aws_secretsmanager_secret_version" "dns_resolver_ip" {
  secret_id = data.aws_secretsmanager_secret.dns_resolver_ip.id
}

data "aws_secretsmanager_secret" "dns_resolver_cidr" {
  name = module.secrets_manager_multiple_secrets.secret_names["dns_resolver_cidr"]
}

data "aws_secretsmanager_secret_version" "dns_resolver_cidr" {
  secret_id = data.aws_secretsmanager_secret.dns_resolver_cidr.id
}
