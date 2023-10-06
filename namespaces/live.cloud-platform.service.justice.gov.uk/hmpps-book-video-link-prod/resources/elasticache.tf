################################################################################
# Book video link Application Elasticache for ReDiS
################################################################################

module "hmpps_book_video_link_elasticache_redis" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"
  vpc_name                = var.vpc_name
  application             = var.application
  environment_name        = var.environment-name
  is_production           = var.is_production
  infrastructure_support  = var.infrastructure_support
  team_name               = var.team_name
  business_unit           = var.business_unit
  number_cache_clusters   = var.number_cache_clusters
  node_type               = "cache.t4g.small"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  namespace               = var.namespace
  auth_token_rotated_date = "2023-06-26"

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
    replication_group_id     = module.hmpps_book_video_link_elasticache_redis.replication_group_id
  }
}
