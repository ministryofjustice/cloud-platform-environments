module "ec-cluster-prison-visits-booking-staff" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.2.0"
  vpc_name                = var.vpc_name
  application             = var.application
  environment_name        = var.environment-name
  is_production           = var.is_production
  infrastructure_support  = var.infrastructure_support
  team_name               = var.team_name
  business_unit           = var.business_unit
  number_cache_clusters   = var.number_cache_clusters
  node_type               = "cache.t4g.micro"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  namespace               = var.namespace
  auth_token_rotated_date = "2023-03-21"

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
    member_clusters          = jsonencode(module.ec-cluster-prison-visits-booking-staff.member_clusters)
    url                      = "rediss://dummyuser:${module.ec-cluster-prison-visits-booking-staff.auth_token}@${module.ec-cluster-prison-visits-booking-staff.primary_endpoint_address}:6379"
  }
}
