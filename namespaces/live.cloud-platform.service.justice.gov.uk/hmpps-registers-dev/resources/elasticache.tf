################################################################################
# registers Elasticache for ReDiS
################################################################################

module "hmpps_registers_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.2.0"
  vpc_name               = var.vpc_name
  business_unit          = var.business_unit
  application            = var.hmpps-registers-application
  environment_name       = var.environment-name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  number_cache_clusters  = var.number-cache-clusters
  node_type              = "cache.t4g.micro"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_registers_elasticache_redis" {
  metadata {
    name      = "elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_registers_elasticache_redis.primary_endpoint_address
    auth_token               = module.hmpps_registers_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.hmpps_registers_elasticache_redis.member_clusters)
  }
}
