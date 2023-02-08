################################################################################
# Send Legal Mail to Prisons API Elasticache for ReDiS
################################################################################

module "slmtp_api_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.6"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t2.small"
  engine_version         = "5.0.6"
  parameter_group_name   = aws_elasticache_parameter_group.token_store.name
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "slmtp_api_elasticache_redis" {
  metadata {
    name      = "slmtp-api-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.slmtp_api_elasticache_redis.primary_endpoint_address
    auth_token               = module.slmtp_api_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.slmtp_api_elasticache_redis.member_clusters)
  }
}

resource "aws_elasticache_parameter_group" "token_store" {
  name   = "slmtp-api-preprod-token-store-parameter-group"
  family = "redis5.0"

  # Needed in order to get spring boot to expire items from the redis cache
  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }
}

