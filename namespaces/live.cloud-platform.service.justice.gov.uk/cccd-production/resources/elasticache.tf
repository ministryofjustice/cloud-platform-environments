################################################################################
# CCCD Application Elasticache for ReDiS
# for sidekiq background job processing and internal API cache
# Size: cache.t2.small (1vCPU, 1.55Gib, low/moderate)
# https://aws.amazon.com/elasticache/pricing/
################################################################################

module "cccd_elasticache_redis" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"

  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment-name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  namespace              = var.namespace
  business_unit          = var.business_unit

  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  number_cache_clusters   = "3"
  node_type               = "cache.t4g.small"
  auth_token_rotated_date = "2023-11-01"
}

resource "kubernetes_secret" "cccd_elasticache_redis" {
  metadata {
    name      = "cccd-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.cccd_elasticache_redis.primary_endpoint_address
    auth_token               = module.cccd_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.cccd_elasticache_redis.member_clusters)
    url                      = "rediss://:${module.cccd_elasticache_redis.auth_token}@${module.cccd_elasticache_redis.primary_endpoint_address}:6379"
  }
}
