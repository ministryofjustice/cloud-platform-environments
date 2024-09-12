module "redis-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.1.0"

  vpc_name = var.vpc_name

  application             = var.application
  environment_name        = var.environment-name
  is_production           = var.is_production
  infrastructure_support  = var.infrastructure_support
  team_name               = var.team_name
  business_unit           = var.business_unit
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  namespace               = var.namespace
  snapshot_window         = "22:00-23:59"
  maintenance_window      = "sun:00:00-sun:03:00"
  node_type               = "cache.t4g.micro"
  auth_token_rotated_date = "2023-05-22"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "redis-elasticache" {
  metadata {
    name      = "elasticache-hmpps-book-secure-move-frontend-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis-elasticache.primary_endpoint_address
    auth_token               = module.redis-elasticache.auth_token
    replication_group_id     = module.redis-elasticache.replication_group_id
  }
}
