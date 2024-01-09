module "redis" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis cluster configuration
  node_type            = "cache.t4g.small"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "redis_secrets" {
  metadata {
    name      = "elasticache-grc-prod"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis.primary_endpoint_address
    member_clusters          = jsonencode(module.redis.member_clusters)
    auth_token               = module.redis.auth_token
    replication_group_id     = module.redis.replication_group_id
    url                      = "rediss://:${module.redis.auth_token}@${module.redis.primary_endpoint_address}:6379"

  }
}