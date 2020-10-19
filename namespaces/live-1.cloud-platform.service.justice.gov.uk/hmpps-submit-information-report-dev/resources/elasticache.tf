################################################################################
# Manage Intelligence Application Elasticache for ReDiS
################################################################################

module "submit_information_report_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=4.2"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
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

resource "kubernetes_secret" "submit_information_report_elasticache_redis" {
  metadata {
    name      = "submit-information-report-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.submit_information_report_elasticache_redis.primary_endpoint_address
    auth_token               = module.submit_information_report_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.submit_information_report_elasticache_redis.member_clusters)
  }
}

