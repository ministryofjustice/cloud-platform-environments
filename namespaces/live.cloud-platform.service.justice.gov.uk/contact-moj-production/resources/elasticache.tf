################################################################################
# Contact MOJ (Correspondence Tool Public)
# Application Elasticache for Redis (for Sidekiq background job processing)
#################################################################################

module "contact_moj_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  node_type              = "cache.t4g.small"
  namespace              = var.namespace

  auth_token_rotated_date = "2023-04-06"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "contact_moj_elasticache_redis" {
  metadata {
    name      = "contact-moj-elasticache-redis-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.contact_moj_elasticache_redis.primary_endpoint_address
    auth_token               = module.contact_moj_elasticache_redis.auth_token
    url                      = "rediss://appuser:${module.contact_moj_elasticache_redis.auth_token}@${module.contact_moj_elasticache_redis.primary_endpoint_address}:6379"
  }
}

