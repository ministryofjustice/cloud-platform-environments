module "redis" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.1.0" # use the latest release

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis cluster configuration
  node_type               = "cache.t4g.micro"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  snapshot_window         = "01:00-02:00"
  #auth_token_rotated_date = "2023-07-04"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "laa-provider-details-api-redis-secrets" {
  metadata {
    name      = "laa-provider-details-api-redis-secrets"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis.primary_endpoint_address
    member_clusters          = jsonencode(module.redis.member_clusters)
    auth_token               = module.redis.auth_token
    replication_group_id     = module.redis.replication_group_id
  }
}