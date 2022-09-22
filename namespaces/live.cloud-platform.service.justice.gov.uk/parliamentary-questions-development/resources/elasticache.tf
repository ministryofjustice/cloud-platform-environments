################################################################################
# Parliamentary Questions
# Application Elasticache for Redis (for Sidekiq background job processing)
#################################################################################

module "parliamentary_questions_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.4"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = "DEX uhura"
  application            = var.application
  is-production          = "false"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "parliamentary_questions_elasticache_redis" {
  metadata {
    name      = "parliamentary-questions-elasticache-redis-output"
    namespace = "parliamentary-questions-development"
  }

  data = {
    primary_endpoint_address = module.parliamentary_questions_elasticache_redis.primary_endpoint_address
    auth_token               = module.parliamentary_questions_elasticache_redis.auth_token
    url                      = "rediss://appuser:${module.parliamentary_questions_elasticache_redis.auth_token}@${module.parliamentary_questions_elasticache_redis.primary_endpoint_address}:6379"
  }
}

