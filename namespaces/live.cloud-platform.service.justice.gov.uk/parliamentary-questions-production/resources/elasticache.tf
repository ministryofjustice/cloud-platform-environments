################################################################################
# Parliamentary Questions
# Application Elasticache for Redis (for Sidekiq background job processing)
#################################################################################

module "parliamentary_questions_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  node_type              = "cache.t4g.small"
  namespace              = var.namespace

  auth_token_rotated_date = "2023-04-05"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "parliamentary_questions_elasticache_redis" {
  metadata {
    name      = "parliamentary-questions-elasticache-redis-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.parliamentary_questions_elasticache_redis.primary_endpoint_address
    auth_token               = module.parliamentary_questions_elasticache_redis.auth_token
    url                      = "rediss://appuser:${module.parliamentary_questions_elasticache_redis.auth_token}@${module.parliamentary_questions_elasticache_redis.primary_endpoint_address}:6379"
  }
}
