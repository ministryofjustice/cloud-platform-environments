module "hmpps_assess_risks_and_needs_handover_service_test_elasticache_redis" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis cluster configuration
  node_type               = "cache.t4g.micro"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "hmpps_assess_risks_and_needs_handover_service_test_elasticache_redis" {
  metadata {
    name      = "hmpps-assess-risks-and-needs-handover-service-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_assess_risks_and_needs_handover_service_test_elasticache_redis.primary_endpoint_address
    auth_token               = module.hmpps_assess_risks_and_needs_handover_service_test_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.hmpps_assess_risks_and_needs_handover_service_test_elasticache_redis.member_clusters)
    replication_group_id     = module.hmpps_assess_risks_and_needs_handover_service_test_elasticache_redis.replication_group_id
  }
}