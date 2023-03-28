module "elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  number_cache_clusters  = var.number_cache_clusters
  business-unit          = var.business_unit
  node_type              = "cache.t2.small"
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "elasticache_redis" {
  metadata {
    name      = "elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache_redis.primary_endpoint_address
    auth_token               = module.elasticache_redis.auth_token
    member_clusters          = jsonencode(module.elasticache_redis.member_clusters)
  }
}

