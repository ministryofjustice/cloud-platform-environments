module "lcdui_elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.1.0"

  vpc_name               = var.vpc_name
  application            = var.application
  environment_name       = var.environment-name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  namespace              = var.namespace
  business_unit          = var.business_unit

  engine_version        = "7.0"
  parameter_group_name  = "default.redis7"
  number_cache_clusters = "2"
  node_type             = "cache.t4g.micro"
}

resource "kubernetes_secret" "lcdui_elasticache" {
  metadata {
    name      = "lcdui-elasticache"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.lcdui_elasticache.primary_endpoint_address
    auth_token               = module.lcdui_elasticache.auth_token
    member_clusters          = jsonencode(module.lcdui_elasticache.member_clusters)
    url                      = "rediss://dummyuser:${module.lcdui_elasticache.auth_token}@${module.lcdui_elasticache.primary_endpoint_address}:6379"
  }
}
