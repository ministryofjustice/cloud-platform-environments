module "csc_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t4g.micro"
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "csc_redis" {
  metadata {
    name      = "csc-redis"
    namespace = var.namespace
  }

  data = {
    REDIS_HOST      = module.csc_redis.primary_endpoint_address
    REDIS_PASSWORD  = module.csc_redis.auth_token
    member_clusters = jsonencode(module.csc_redis.member_clusters)
  }
}
