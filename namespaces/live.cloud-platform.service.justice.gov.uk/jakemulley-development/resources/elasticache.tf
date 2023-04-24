module "redis_7" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis configuration
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  node_type            = "cache.t4g.micro"

  # Tags
  team_name              = var.team_name
  namespace              = var.namespace
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
}

resource "kubernetes_secret" "redis_7" {
  metadata {
    name      = "${var.team_name}-ec-cluster-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis_7.primary_endpoint_address
    member_clusters          = jsonencode(module.redis_7.member_clusters)
    auth_token               = module.redis_7.auth_token
    access_key_id            = module.redis_7.access_key_id
    secret_access_key        = module.redis_7.secret_access_key
    replication_group_id     = module.redis_7.replication_group_id
  }
}
