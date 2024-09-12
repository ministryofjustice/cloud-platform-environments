################################################################################
# Pathfinder Application Elasticache for ReDiS
################################################################################

module "pathfinder_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.1.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment_name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t4g.micro"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace
}

resource "kubernetes_secret" "pathfinder_elasticache_redis" {
  metadata {
    name      = "pathfinder-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.pathfinder_elasticache_redis.primary_endpoint_address
    auth_token               = module.pathfinder_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.pathfinder_elasticache_redis.member_clusters)
  }
}
