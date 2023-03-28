
module "elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  business-unit          = var.business_unit
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t2.small"
  engine_version         = "6.x"
  parameter_group_name   = "default.redis6.x"
  namespace              = var.namespace

  auth_token_rotated_date = "2023-02-21"

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
    access_key_id            = module.elasticache_redis.access_key_id
    secret_access_key        = module.elasticache_redis.secret_access_key
    replication_group_id     = module.elasticache_redis.replication_group_id
  }
}

