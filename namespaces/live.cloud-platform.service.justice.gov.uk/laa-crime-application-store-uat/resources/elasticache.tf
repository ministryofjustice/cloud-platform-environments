module "crm_elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"

  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  namespace              = var.namespace
  business_unit          = var.business_unit

  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  node_type            = "cache.t4g.micro"
}

resource "kubernetes_secret" "crm_elasticache" {
  metadata {
    name      = "crm-elasticache"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.crm_elasticache.primary_endpoint_address
    member_clusters          = jsonencode(module.crm_elasticache.member_clusters)
    auth_token               = module.crm_elasticache.auth_token
    replication_group_id     = module.crm_elasticache.replication_group_id
  }
}
