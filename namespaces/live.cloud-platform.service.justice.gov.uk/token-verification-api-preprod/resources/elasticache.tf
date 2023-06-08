################################################################################
# Use of force Application Elasticache for ReDiS
################################################################################

module "tva_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t4g.micro"
  engine_version         = "7.0"
  parameter_group_name   = aws_elasticache_parameter_group.token_store.name
  namespace              = var.namespace
  business-unit          = var.business_unit

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "tva_elasticache_redis" {
  metadata {
    name      = "tva-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.tva_elasticache_redis.primary_endpoint_address
    auth_token               = module.tva_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.tva_elasticache_redis.member_clusters)
  }
}

resource "aws_elasticache_parameter_group" "token_store" {
  name   = "tva-token-store-parameter-group-preprod"
  family = "redis7"

  # Needed in order to get spring boot to expire items from the redis cache
  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }
}
