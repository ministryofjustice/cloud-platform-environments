module "hmpps_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment-name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t4g.micro"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_redis" {
  metadata {
    name      = "hmpps-redis"
    namespace = var.namespace
  }

  data = {
    REDIS_HOST      = module.hmpps_redis.primary_endpoint_address
    REDIS_PASSWORD  = module.hmpps_redis.auth_token
    member_clusters = jsonencode(module.hmpps_redis.member_clusters)
  }
}
resource "kubernetes_secret" "tva_elasticache_redis" {
  metadata {
    name      = "tva-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_redis.primary_endpoint_address
    auth_token               = module.hmpps_redis.auth_token
    member_clusters          = jsonencode(module.hmpps_redis.member_clusters)
  }
}

resource "aws_elasticache_parameter_group" "token_store" {
  name   = "tva-token-store-parameter-group"
  family = "redis7"

  # Needed in order to get spring boot to expire items from the redis cache
  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }
}
