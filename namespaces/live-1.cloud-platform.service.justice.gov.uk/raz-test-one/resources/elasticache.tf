module "raz_test_ec_cluster" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.3"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  namespace              = var.namespace
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "raz_test_ec_cluster" {
  metadata {
    name      = "raz-test-one-ec-cluster"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.raz_test_ec_cluster.primary_endpoint_address
    member_clusters          = jsonencode(module.raz_test_ec_cluster.member_clusters)
    auth_token               = module.raz_test_ec_cluster.auth_token
  }
}
