module "check_my_diary_redis" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name                = var.vpc_name
  application             = var.application
  environment-name        = var.environment
  is-production           = var.is_production
  infrastructure-support  = var.infrastructure_support
  team_name               = var.team_name
  business-unit           = var.business_unit
  number_cache_clusters   = var.number_cache_clusters
  node_type               = "cache.t4g.micro"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  namespace               = var.namespace
  auth_token_rotated_date = "2023-02-21:14:00"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "check_my_diary_redis" {
  metadata {
    name      = "elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.check_my_diary_redis.primary_endpoint_address
    auth_token               = module.check_my_diary_redis.auth_token
    member_clusters          = jsonencode(module.check_my_diary_redis.member_clusters)
  }
}
