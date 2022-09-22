module "redis" {
  source       = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=update-elasticache-vpc-name"
  cluster_name = var.vpc_name

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  node_type             = "cache.t2.small"
  engine_version        = "5.0.6"
  parameter_group_name  = "default.redis5.0"
  number_cache_clusters = "2"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "redis" {
  metadata {
    name      = "elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis.primary_endpoint_address
    member_clusters          = jsonencode(module.redis.member_clusters)
    auth_token               = module.redis.auth_token
  }
}
