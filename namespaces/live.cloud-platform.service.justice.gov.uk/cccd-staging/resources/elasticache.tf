################################################################################
# CCCD Application Elasticache for ReDiS
# for sidekiq background job processing and internal API cache
################################################################################

module "cccd_elasticache_redis" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"

  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  namespace              = var.namespace
  business-unit          = var.business_unit

  engine_version        = "6.x"
  parameter_group_name  = "default.redis6.x"
  number_cache_clusters = "3"
  node_type             = "cache.t4g.small"
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
