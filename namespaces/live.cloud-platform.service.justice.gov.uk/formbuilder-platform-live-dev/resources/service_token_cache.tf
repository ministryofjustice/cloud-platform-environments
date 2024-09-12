locals {
  sa_name = "formbuilder-service-token-cache-cross-namespace-live-dev"
}

module "service-token-cache-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.1.0"

  vpc_name = var.vpc_name

  application            = "formbuilderservice-token-cache"
  environment_name       = var.environment-name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  node_type              = "cache.t4g.medium"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "service-token-cache-elasticache" {
  metadata {
    name      = "elasticache-formbuilder-service-token-cache-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data = {
    primary_endpoint_address = module.service-token-cache-elasticache.primary_endpoint_address
    auth_token               = module.service-token-cache-elasticache.auth_token
  }
}

resource "kubernetes_service_account" "service_token_cache_service_account" {
  metadata {
    name      = local.sa_name
    namespace = var.namespace
  }

  secret {
    name = "${local.sa_name}-token"
  }

  automount_service_account_token = true
}

resource "kubernetes_secret_v1" "service_token_cache_token" {
  metadata {
    name      = "${local.sa_name}-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = local.sa_name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account.service_token_cache_service_account
  ]
}