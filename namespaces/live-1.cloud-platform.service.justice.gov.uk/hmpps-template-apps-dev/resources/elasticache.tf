################################################################################
# HMPPs Typescript Template Application Elasticache
################################################################################

module "hmpps_template_typescript_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.1"
  cluster_name           = var.cluster_name
  application            = "hmpps-template-typescript"
  environment-name       = var.environment
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  number_cache_clusters  = var.number_cache_clusters
  node_type              = "cache.t2.small"
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_template_typescript_elasticache_redis" {
  metadata {
    name      = "hmpps-template-typescript-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_template_typescript_elasticache_redis.primary_endpoint_address
    auth_token               = module.hmpps_template_typescript_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.hmpps_template_typescript_elasticache_redis.member_clusters)
  }
}

