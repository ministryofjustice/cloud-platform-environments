module "crime_apps_ec_cluster" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=4.2"

  // The first two inputs are provided by the pipeline for cloud-platform. See the example for more detail.
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace
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
  }
}
