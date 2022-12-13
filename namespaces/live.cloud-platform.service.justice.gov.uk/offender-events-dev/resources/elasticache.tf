################################################################################
# registers Elasticache for ReDiS
################################################################################

module "offender_events_ui_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.6"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name
  number_cache_clusters  = var.number-cache-clusters
  node_type              = "cache.t2.small"
  engine_version         = "6.x"
  parameter_group_name   = "default.redis6.x"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "offender_events_ui_elasticache_redis" {
  metadata {
    name      = "offender-events-ui-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.offender_events_ui_elasticache_redis.primary_endpoint_address
    auth_token               = module.offender_events_ui_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.offender_events_ui_elasticache_redis.member_clusters)
  }
}

resource "aws_elasticache_parameter_group" "event_store" {
  name   = "offender-events-ui-event-parameter-group"
  family = "redis6.x"

  # Needed in order to get spring boot to expire items from the redis cache
  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }
}


