module "nsm_elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"

  vpc_name               = var.vpc_name
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name
  namespace              = var.namespace
  business-unit          = var.business_unit

  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  node_type              = "cache.t4g.micro"
}

resource "kubernetes_secret" "nsm_elasticache" {
  metadata {
    name      = "nsm-elasticache"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis.primary_endpoint_address
    member_clusters          = jsonencode(module.redis.member_clusters)
    auth_token               = module.redis.auth_token
    replication_group_id     = module.redis.replication_group_id
  }
}
