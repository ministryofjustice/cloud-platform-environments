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
  environment-name       = "production"
  infrastructure-support = "staffservices@digital.justice.gov.uk"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  node_type              = "cache.t4g.small"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "contact_moj_elasticache_redis" {
  metadata {
    name      = "contact-moj-elasticache-redis-output"
    namespace = "contact-moj-production"
  }

  data = {
    primary_endpoint_address = module.contact_moj_elasticache_redis.primary_endpoint_address
    auth_token               = module.contact_moj_elasticache_redis.auth_token
    url                      = "rediss://appuser:${module.contact_moj_elasticache_redis.auth_token}@${module.contact_moj_elasticache_redis.primary_endpoint_address}:6379"
  }
}

