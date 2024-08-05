module "ec-cluster-offender-management-allocation-manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  application            = "offender-management-allocation-manager"
  is_production          = var.is_production
  node_type              = "cache.t4g.small"
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  business_unit          = var.business_unit
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace

  auth_token_rotated_date = "2023-04-06T11:12:00Z"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "redis-preprod" {
  metadata {
    name      = "allocation-elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address
    auth_token               = module.ec-cluster-offender-management-allocation-manager.auth_token
    url                      = "rediss://dummyuser:${module.ec-cluster-offender-management-allocation-manager.auth_token}@${module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address}:6379"
  }
}
