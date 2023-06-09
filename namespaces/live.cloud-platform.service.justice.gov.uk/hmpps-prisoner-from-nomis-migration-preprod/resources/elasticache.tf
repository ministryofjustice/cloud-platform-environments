module "hmpps_redis" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name                = var.vpc_name
  application             = var.application_sync_dashboard
  environment-name        = var.environment
  is-production           = var.is_production
  infrastructure-support  = var.infrastructure_support
  team_name               = var.team_name
  business-unit           = var.business_unit
  number_cache_clusters   = var.number_cache_clusters
  node_type               = var.node-type
  engine_version          = "6.x"
  parameter_group_name    = "default.redis6.x"
  namespace               = var.namespace
  auth_token_rotated_date = "2023-02-21:14:00"

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
