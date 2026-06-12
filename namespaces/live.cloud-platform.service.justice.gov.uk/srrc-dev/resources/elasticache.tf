################################################################################
# SRRC Application Elasticache for ReDiS
# for sidekiq background job processing and internal API cache
################################################################################

module "srrc_elasticache_redis" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"

  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  namespace              = var.namespace
  business_unit          = var.business_unit

  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  number_cache_clusters   = "2"
  node_type               = "cache.t4g.micro"
  auth_token_rotated_date = "2023-11-14"
}

resource "kubernetes_secret" "srrc_elasticache_redis" {
  metadata {
    name      = "srrc-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.srrc_elasticache_redis.primary_endpoint_address
    auth_token               = module.srrc_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.srrc_elasticache_redis.member_clusters)
    url                      = "rediss://:${module.srrc_elasticache_redis.auth_token}@${module.srrc_elasticache_redis.primary_endpoint_address}:6379"
  }
}
