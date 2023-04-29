################################################################################
# Track a Query (Correspondence Tool Staff)
# Application Elasticache for Redis (for Sidekiq background job processing)
#################################################################################

module "track_a_query_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"
  vpc_name               = var.vpc_name
  team_name              = "correspondence"
  business-unit          = "Central Digital"
  application            = "track-a-query"
  is-production          = "false"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  node_type              = "cache.t4g.micro"
  namespace              = var.namespace

  auth_token_rotated_date = "2023-04-03"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "track_a_query_elasticache_redis" {
  metadata {
    name      = "track-a-query-elasticache-redis-output"
    namespace = "track-a-query-qa"
  }

  data = {
    primary_endpoint_address = module.track_a_query_elasticache_redis.primary_endpoint_address
    auth_token               = module.track_a_query_elasticache_redis.auth_token
    url                      = "rediss://appuser:${module.track_a_query_elasticache_redis.auth_token}@${module.track_a_query_elasticache_redis.primary_endpoint_address}:6379"
  }
}

