################################################################################
# Contact MOJ (Correspondence Tool Public)
# Application Elasticache for Redis (for Sidekiq background job processing)
#################################################################################

module "contact_moj_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"
  vpc_name               = var.vpc_name
  team_name              = "correspondence"
  business-unit          = "Central Digital"
  application            = "contact-moj"
  is-production          = "false"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  node_type              = "cache.t4g.micro"
  namespace              = var.namespace

  auth_token_rotated_date = "2023-03-28"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "contact_moj_elasticache_redis" {
  metadata {
    name      = "contact-moj-elasticache-redis-output"
    namespace = "contact-moj-staging"
  }

  data = {
    primary_endpoint_address = module.contact_moj_elasticache_redis.primary_endpoint_address
    auth_token               = module.contact_moj_elasticache_redis.auth_token
    url                      = "rediss://appuser:${module.contact_moj_elasticache_redis.auth_token}@${module.contact_moj_elasticache_redis.primary_endpoint_address}:6379"
  }
}

