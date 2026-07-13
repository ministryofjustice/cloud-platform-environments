module "elasticache_redis" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis cluster configuration
  node_type               = "cache.t4g.micro"
  engine_version          = "7.1"
  parameter_group_name    = "default.redis7"
  auth_token_rotated_date = "2026-07-13"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }

  enable_irsa            = true
}

resource "kubernetes_secret" "redis_secrets" {
  metadata {
    name      = "elasticache-redis-instance-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache_redis.primary_endpoint_address
    member_clusters          = jsonencode(module.elasticache_redis.member_clusters)
    auth_token               = module.elasticache_redis.auth_token
    replication_group_id     = module.elasticache_redis.replication_group_id
  }
}