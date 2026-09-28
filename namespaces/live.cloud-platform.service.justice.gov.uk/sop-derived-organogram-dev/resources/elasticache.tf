/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "redis" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=8.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis cluster configuration
  node_type               = "cache.t4g.micro"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  auth_token_rotated_date = "2026-07-31"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true
}

resource "kubernetes_secret" "redis_secrets" {
  metadata {
    name      = "elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis.primary_endpoint_address
    member_clusters          = jsonencode(module.redis.member_clusters)
    auth_token               = module.redis.auth_token
    replication_group_id     = module.redis.replication_group_id
  }
}
