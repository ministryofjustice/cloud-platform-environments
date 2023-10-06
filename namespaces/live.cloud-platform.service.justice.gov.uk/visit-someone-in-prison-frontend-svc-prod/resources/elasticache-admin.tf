################################################################################
# VSiP Admin Application Elasticache
################################################################################

module "elasticache_redis_admin" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"
  vpc_name                = var.vpc_name
  application             = var.application
  environment_name        = var.environment
  is_production           = var.is_production
  infrastructure_support  = var.infrastructure_support
  team_name               = var.team_name
  business_unit           = var.business_unit
  number_cache_clusters   = var.number_cache_clusters
  node_type               = "cache.t4g.small"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  namespace               = var.namespace
  auth_token_rotated_date = "2023-05-01"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "elasticache_redis_admin" {
  metadata {
    name      = "elasticache-redis-admin"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache_redis_admin.primary_endpoint_address
    auth_token               = module.elasticache_redis_admin.auth_token
    member_clusters          = jsonencode(module.elasticache_redis_admin.member_clusters)
  }
}
