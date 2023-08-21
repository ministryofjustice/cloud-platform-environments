module "elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  engine_version        = "7.0"
  parameter_group_name  = "default.redis7"
  node_type             = "cache.t4g.micro"
  number_cache_clusters = "2"

  auth_token_rotated_date = "2023-04-25"

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
    access_key_id            = module.elasticache_redis.access_key_id
    secret_access_key        = module.elasticache_redis.secret_access_key
    member_clusters          = jsonencode(module.elasticache_redis.member_clusters)
    url                      = "rediss://${module.elasticache_redis.auth_token}@${module.elasticache_redis.primary_endpoint_address}:6379"
  }
}
