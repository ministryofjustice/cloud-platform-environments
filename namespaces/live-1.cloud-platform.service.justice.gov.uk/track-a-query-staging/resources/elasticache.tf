################################################################################
# Track a Query (Correspondence Tool Staff)
# Application Elasticache for Redis (for Sidekiq background job processing)
#################################################################################

module "track_a_query_elasticache_redis" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=3.1"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "correspondence"
  business-unit          = "Central Digital"
  application            = "track-a-query"
  is-production          = "true"
  environment-name       = "staging"
  infrastructure-support = "correspondence-support@digital.justice.gov.uk"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "track_a_query_elasticache_redis" {
  metadata {
    name      = "track-a-query-elasticache-redis-output"
    namespace = "track-a-query-staging"
  }

  data {
    primary_endpoint_address = "${module.track_a_query_elasticache_redis.primary_endpoint_address}"
    auth_token               = "${module.track_a_query_elasticache_redis.auth_token}"
    url                      = "rediss://appuser:${module.track_a_query_elasticache_redis.auth_token}@${module.track_a_query_elasticache_redis.primary_endpoint_address}:6379"
  }
}
