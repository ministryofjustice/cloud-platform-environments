module "ec-cluster-offender-management-allocation-manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"
  node_type              = "cache.t4g.small"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  application            = "offender-management-allocation-manager"
  is-production          = var.is_production
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  business-unit          = var.business_unit
  engine_version         = "5.0.6"
  parameter_group_name   = "default.redis5.0"
  namespace              = var.namespace

  auth_token_rotated_date = "2023-04-05T17:15:00Z"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ec-cluster-offender-management-allocation-manager-staging" {
  metadata {
    name      = "elasticache-offender-management-allocation-manager-token-cache-${var.environment_name}"
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

resource "kubernetes_secret" "ec-cluster-offender-management-allocation-manager-test" {
  metadata {
    name      = "elasticache-offender-management-allocation-manager-token-cache-test"
    namespace = "offender-management-test"
  }

  data = {
    primary_endpoint_address = module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address
    auth_token               = module.ec-cluster-offender-management-allocation-manager.auth_token
    url                      = "rediss://dummyuser:${module.ec-cluster-offender-management-allocation-manager.auth_token}@${module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address}:6379"
  }
}

resource "kubernetes_secret" "ec-cluster-offender-management-allocation-manager-test2" {
  metadata {
    name      = "elasticache-offender-management-allocation-manager-token-cache-test2"
    namespace = "offender-management-test2"
  }

  data = {
    primary_endpoint_address = module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address
    auth_token               = module.ec-cluster-offender-management-allocation-manager.auth_token
    url                      = "rediss://dummyuser:${module.ec-cluster-offender-management-allocation-manager.auth_token}@${module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address}:6379"
  }
}
