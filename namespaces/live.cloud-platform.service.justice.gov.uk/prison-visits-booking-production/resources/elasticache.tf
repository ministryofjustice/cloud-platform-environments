module "ec-cluster-prison-visits-booking-staff" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.2.0"
  vpc_name                = var.vpc_name
  team_name               = var.team_name
  application             = "prison-visits-booking-staff"
  node_type               = "cache.t4g.small"
  is_production           = var.is_production
  environment_name        = var.environment-name
  business_unit           = var.business_unit
  infrastructure_support  = var.infrastructure_support
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  namespace               = var.namespace
  auth_token_rotated_date = "2023-05-15"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ec-cluster-prison-visits-booking-staff" {
  metadata {
    name      = "elasticache-prison-visits-booking-token-cache-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.ec-cluster-prison-visits-booking-staff.primary_endpoint_address
    auth_token               = module.ec-cluster-prison-visits-booking-staff.auth_token
    url                      = "rediss://dummyuser:${module.ec-cluster-prison-visits-booking-staff.auth_token}@${module.ec-cluster-prison-visits-booking-staff.primary_endpoint_address}:6379"
  }
}
