module "redis-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"

  vpc_name = var.vpc_name

  application             = var.application
  environment-name        = var.environment-name
  is-production           = var.is_production
  infrastructure-support  = var.infrastructure_support
  team_name               = var.team_name
  business-unit           = var.business_unit
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  namespace               = var.namespace
  snapshot_window         = "22:00-23:59"
  maintenance_window      = "sun:00:00-sun:03:00"
  node_type               = "cache.t4g.medium"
  auth_token_rotated_date = "2023-05-28"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "redis-elasticache" {
  metadata {
    name      = "elasticache-hmpps-book-secure-move-frontend-production"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis-elasticache.primary_endpoint_address
    auth_token               = module.redis-elasticache.auth_token
    access_key_id            = module.redis-elasticache.access_key_id
    secret_access_key        = module.redis-elasticache.secret_access_key
    replication_group_id     = module.redis-elasticache.replication_group_id
  }
}
