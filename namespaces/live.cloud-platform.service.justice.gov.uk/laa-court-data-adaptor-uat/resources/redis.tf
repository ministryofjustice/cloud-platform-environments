module "crime_apps_ec_cluster" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=7.2.0"

  # The first two inputs are provided by the pipeline for cloud-platform. See the example for more detail.
  vpc_name                = var.vpc_name
  team_name               = var.team_name
  business_unit           = var.business_unit
  application             = var.application
  is_production           = var.is_production
  environment_name        = var.environment_name
  infrastructure_support  = var.infrastructure_support
  namespace               = var.namespace
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  node_type               = "cache.t4g.micro"
  auth_token_rotated_date = "2023-07-04"
  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "crime_apps_ec_cluster" {
  metadata {
    name      = "ec-cluster-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.crime_apps_ec_cluster.primary_endpoint_address
    auth_token               = module.crime_apps_ec_cluster.auth_token
    url                      = "rediss://:${module.crime_apps_ec_cluster.auth_token}@${module.crime_apps_ec_cluster.primary_endpoint_address}:6379"
    replication_group_id     = module.crime_apps_ec_cluster.replication_group_id
  }
}
