################################################################################
# Pathfinder Application Elasticache for ReDiS
################################################################################

module "pathfinder_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  business-unit          = var.business_unit
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t4g.micro"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
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
