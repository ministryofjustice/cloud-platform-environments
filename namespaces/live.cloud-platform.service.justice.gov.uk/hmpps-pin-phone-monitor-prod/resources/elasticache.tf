module "pcms_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  business-unit          = var.business_unit
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "db.t4g.small"
  engine_version         = "6.x"
  parameter_group_name   = "default.redis6.x"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pcms_elasticache_redis" {
  metadata {
    name      = "pcms-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.pcms_elasticache_redis.primary_endpoint_address
    auth_token               = module.pcms_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.pcms_elasticache_redis.member_clusters)
  }
}
