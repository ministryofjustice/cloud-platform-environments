module "hmpps_assessments_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  namespace              = var.namespace
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  node_type              = "cache.t2.small"
  engine_version         = "6.x"
  parameter_group_name   = "default.redis6.x"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_assessments_elasticache_redis" {
  metadata {
    name      = "hmpps-assessments-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_assessments_elasticache_redis.primary_endpoint_address
    auth_token               = module.hmpps_assessments_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.hmpps_assessments_elasticache_redis.member_clusters)
  }
}
