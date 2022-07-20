################################################################################
# hpa Elasticache for ReDiS
################################################################################

module "hmpps_hpa_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.3"
  cluster_name           = var.cluster_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name
  number_cache_clusters  = var.number_cache_clusters
  node_type              = var.node-type
  engine_version         = "6.x"
  parameter_group_name   = "default.redis6.x"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_hpa_redis" {
  metadata {
    name      = "elasticache-redis"
    namespace = var.namespace
  }

  data = {
    REDIS_HOST      = module.hmpps_hpa_redis.primary_endpoint_address
    REDIS_PASSWORD  = module.hmpps_hpa_redis.auth_token
    member_clusters = jsonencode(module.hmpps_hpa_redis.member_clusters)
  }
}
