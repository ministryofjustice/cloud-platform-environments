module "elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.0.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis cluster configuration
  node_type               = "cache.t4g.micro"
  engine_version          = "7.1"
  parameter_group_name    = "default.redis7"
  auth_token_rotated_date = "2025-10-27"

  # Tags
  business_unit           = var.business_unit
  application             = var.application
  is_production           = var.is_production
  team_name               = var.team_name
  namespace               = var.namespace
  environment_name        = var.environment
  infrastructure_support  = var.infrastructure_support
}

resource "kubernetes_secret" "elasticache" {
  metadata {
    name      = "elasticache-laa-civil-decide-uat"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.elasticache.primary_endpoint_address
    member_clusters          = jsonencode(module.elasticache.member_clusters)
    auth_token               = module.elasticache.auth_token
    replication_group_id     = module.elasticache.replication_group_id
    url                      = "rediss://:${module.elasticache.auth_token}@${module.elasticache.primary_endpoint_address}:6379"
  }
}
