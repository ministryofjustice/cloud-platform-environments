module "redis-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.1.0"

  vpc_name = var.vpc_name

  application             = var.application
  environment_name        = var.environment-name
  is_production           = var.is_production
  infrastructure_support  = var.infrastructure_support
  team_name               = var.team_name
  business_unit           = var.business_unit
  engine_version          = "7.0"
  parameter_group_name    = aws_elasticache_parameter_group.basm_api_redis.name
  namespace               = var.namespace
  snapshot_window         = var.backup_window
  maintenance_window      = var.maintenance_window
  node_type               = "cache.t4g.micro"
  auth_token_rotated_date = "2023-05-23"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "redis-elasticache" {
  metadata {
    name      = "elasticache-hmpps-book-secure-move-api-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis-elasticache.primary_endpoint_address
    auth_token               = module.redis-elasticache.auth_token
    url                      = "rediss://:${module.redis-elasticache.auth_token}@${module.redis-elasticache.primary_endpoint_address}:6379"
    replication_group_id     = module.redis-elasticache.replication_group_id
  }
}

resource "aws_elasticache_parameter_group" "basm_api_redis" {
  name   = "basm-api-redis-parameter-group-uat"
  family = "redis7"

  # Prevent Redis from evicting Sidekiq data
  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}
