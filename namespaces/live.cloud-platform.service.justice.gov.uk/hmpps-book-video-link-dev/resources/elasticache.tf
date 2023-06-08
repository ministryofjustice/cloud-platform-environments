################################################################################
# Book video link Application Elasticache for ReDiS
################################################################################

module "hmpps_book_video_link_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"
  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  business-unit          = var.business_unit
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

resource "kubernetes_secret" "hmpps_book_video_link_elasticache_redis" {
  metadata {
    name      = "hmpps-book-video-link-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_book_video_link_elasticache_redis.primary_endpoint_address
    auth_token               = module.hmpps_book_video_link_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.hmpps_book_video_link_elasticache_redis.member_clusters)
  }
}
