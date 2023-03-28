/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "redis_elasticache" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "redis_elasticache" {
  metadata {
    name      = "ec-cluster"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis_elasticache.primary_endpoint_address
    member_clusters          = jsonencode(module.redis_elasticache.member_clusters)
    auth_token               = module.redis_elasticache.auth_token
    url                      = "redis://${module.redis_elasticache.auth_token}@${module.redis_elasticache.primary_endpoint_address}:6379"
  }
}
