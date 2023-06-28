################################################################################
# VSiP Staff Booking Application Elasticache
################################################################################

module "elasticache_redis_staff" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  business-unit          = var.business_unit
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t4g.small"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace
  auth_token_rotated_date = "2023-05-01"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "elasticache_redis_staff" {
  metadata {
    name      = "elasticache-redis-staff"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache_redis_staff.primary_endpoint_address
    auth_token               = module.elasticache_redis_staff.auth_token
    member_clusters          = jsonencode(module.elasticache_redis_staff.member_clusters)
    access_key_id            = module.elasticache_redis_staff.access_key_id
    secret_access_key        = module.elasticache_redis_staff.secret_access_key
  }
}
