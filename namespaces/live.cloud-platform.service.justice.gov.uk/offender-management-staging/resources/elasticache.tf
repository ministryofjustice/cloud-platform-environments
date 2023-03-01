module "ec-cluster-offender-management-allocation-manager" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.0.0"
  node_type              = "cache.m4.xlarge"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  application            = "offender-management-allocation-manager"
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ec-cluster-offender-management-allocation-manager-staging" {
  metadata {
    name      = "elasticache-offender-management-allocation-manager-token-cache-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address
    auth_token               = module.ec-cluster-offender-management-allocation-manager.auth_token
    url                      = "rediss://dummyuser:${module.ec-cluster-offender-management-allocation-manager.auth_token}@${module.ec-cluster-offender-management-allocation-manager.primary_endpoint_address}:6379"
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
