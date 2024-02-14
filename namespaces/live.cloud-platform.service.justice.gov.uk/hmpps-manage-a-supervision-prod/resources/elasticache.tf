module "elasticache" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  node_type            = "cache.t4g.micro"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
}

resource "kubernetes_secret" "elasticache_redis" {
  metadata {
    name      = "elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache.primary_endpoint_address
    auth_token               = module.elasticache.auth_token
    member_clusters          = jsonencode(module.elasticache.member_clusters)
    replication_group_id     = module.elasticache.replication_group_id
  }
}
