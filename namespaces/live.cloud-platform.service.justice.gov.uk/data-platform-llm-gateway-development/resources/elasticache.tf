module "elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.0.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis cluster configuration
  node_type            = "cache.t4g.medium"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "elasticache" {
  metadata {
    name      = "elasticache"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache.primary_endpoint_address
    member_clusters          = jsonencode(module.elasticache.member_clusters)
    auth_token               = module.elasticache.auth_token
    replication_group_id     = module.elasticache.replication_group_id
  }
}
