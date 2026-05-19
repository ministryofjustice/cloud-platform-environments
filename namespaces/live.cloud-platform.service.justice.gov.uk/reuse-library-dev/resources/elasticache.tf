module "reuse_library_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  number_cache_clusters  = var.number_cache_clusters
  business_unit          = var.business_unit
  node_type              = "cache.t4g.micro"
  engine_version         = "9.0"
  parameter_group_name   = "default.redis9"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  enable_irsa = true
}

resource "kubernetes_secret" "reuse_library_elasticache_redis" {
  metadata {
    name      = "reuse-library-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.reuse_library_elasticache_redis.primary_endpoint_address
    auth_token               = module.reuse_library_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.reuse_library_elasticache_redis.member_clusters)
  }
}
