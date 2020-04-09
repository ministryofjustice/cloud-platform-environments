module "dstest_elasticache_redis5" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=4.0"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name

  engine_version        = "5.0.6"
  parameter_group_name  = "default.redis5.0.6"
  number_cache_clusters = "2"
  node_type             = "cache.t2.micro"
}

resource "kubernetes_secret" "dstest_elasticache_redis5" {
  metadata {
    name      = "dstest-elasticache-redis5"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.dstest_elasticache_redis5.primary_endpoint_address
    auth_token               = module.dstest_elasticache_redis5.auth_token
    member_clusters          = jsonencode(module.dstest_elasticache_redis5.member_clusters)
    url                      = "rediss://dummyuser:${module.dstest_elasticache_redis5.auth_token}@${module.dstest_elasticache_redis5.primary_endpoint_address}:6379"
  }
}

