module "hmpps_assessments_elasticache_redis" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"
  vpc_name                = var.vpc_name
  team_name               = var.team_name
  namespace               = var.namespace
  business_unit           = var.business_unit
  application             = var.application
  is_production           = var.is_production
  environment_name        = var.environment_name
  infrastructure_support  = var.infrastructure_support
  node_type               = "cache.t4g.micro"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  auth_token_rotated_date = "2023-04-19"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_assessments_elasticache_redis" {
  metadata {
    name      = "hmpps-assessments-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_assessments_elasticache_redis.primary_endpoint_address
    auth_token               = module.hmpps_assessments_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.hmpps_assessments_elasticache_redis.member_clusters)
    replication_group_id     = module.hmpps_assessments_elasticache_redis.replication_group_id
  }
}
