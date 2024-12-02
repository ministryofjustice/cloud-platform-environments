module "elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.1.0"

  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  namespace              = var.namespace
  business_unit          = var.business_unit

  engine_version          = "7.1"
  parameter_group_name    = "default.redis7"
  number_cache_clusters   = "2"
  node_type               = "cache.t4g.medium"
}

resource "kubernetes_secret" "elasticache" {
  metadata {
    name      = "elasticache-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache.primary_endpoint_address
    auth_token               = module.elasticache.auth_token
    member_clusters          = jsonencode(module.elasticache.member_clusters)
  }
}
