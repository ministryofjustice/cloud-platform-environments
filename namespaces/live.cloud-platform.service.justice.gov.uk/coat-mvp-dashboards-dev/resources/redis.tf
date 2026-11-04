module "athena_cache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"

  vpc_name                = var.vpc_name
  application             = var.application
  environment_name        = var.environment
  is_production           = var.is_production
  infrastructure_support  = var.infrastructure_support
  team_name               = var.team_name
  business_unit           = var.business_unit
  namespace               = var.namespace

  engine_version          = "7.0"
  parameter_group_name    = aws_elasticache_parameter_group.athena_cache.name
  node_type               = "cache.t4g.small"
  auth_token_rotated_date = "2026-11-04"
}

resource "aws_elasticache_parameter_group" "athena_cache" {
  name   = "${var.namespace}-athena-cache"
  family = "redis7"

  # Preserve the last successful snapshot if a refresh runs out of memory.
  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}

resource "kubernetes_secret" "athena_cache" {
  metadata {
    name      = "athena-cache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.athena_cache.primary_endpoint_address
    auth_token = module.athena_cache.auth_token
    member_clusters = jsonencode(module.athena_cache.member_clusters)
    url = "rediss://:${module.athena_cache.auth_token}@${module.athena_cache.primary_endpoint_address}:6379"
  }
}