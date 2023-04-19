module "ec-cluster-offender-management-allocation-manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  application            = "offender-management-allocation-manager"
  is-production          = var.is_production
  node_type              = "cache.m4.large"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  business-unit          = var.business_unit
  engine_version         = "7.0"
  parameter_group_name   = "default.redis7"
  namespace              = var.namespace

  auth_token_rotated_date = "2023-04-11T13:16:00Z"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ec-cluster-offender-management-allocation-manager-production" {
  metadata {
    name      = "elasticache-offender-management-allocation-manager-token-cache-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address
    auth_token               = module.ec-cluster-offender-management-allocation-manager.auth_token
    url                      = "rediss://dummyuser:${module.ec-cluster-offender-management-allocation-manager.auth_token}@${module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address}:6379"
    access_key_id            = module.ec-cluster-offender-management-allocation-manager.access_key_id
    secret_access_key        = module.ec-cluster-offender-management-allocation-manager.secret_access_key
  }
}
