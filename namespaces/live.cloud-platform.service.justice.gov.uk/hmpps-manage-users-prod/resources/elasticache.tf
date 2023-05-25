module "hmpps_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  business-unit          = var.business_unit
  number_cache_clusters  = var.number_cache_clusters
  node_type              = var.node-type
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  maintenance_window     = "sun:23:00-mon:01:00"
  snapshot_window        = "02:00-05:00"
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
