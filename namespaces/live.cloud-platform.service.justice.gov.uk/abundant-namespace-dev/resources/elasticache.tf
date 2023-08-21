module "test_ec_cluster" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.2.0"

  # The first two inputs are provided by the pipeline for cloud-platform. See the example for more detail.
  vpc_name                = var.vpc_name
  team_name               = var.team_name
  business-unit           = var.business_unit
  application             = var.application
  is-production           = var.is_production
  environment-name        = var.environment
  infrastructure-support  = var.infrastructure_support
  namespace               = var.namespace
  node_type               = "cache.t4g.micro"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  auth_token_rotated_date = "2023-02-08"
  providers = {
    aws = aws.london
  }
}


resource "kubernetes_secret" "test_ec_cluster" {
  metadata {
    name      = "test-ec-cluster-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.test_ec_cluster.primary_endpoint_address
    member_clusters          = jsonencode(module.test_ec_cluster.member_clusters)
    auth_token               = module.test_ec_cluster.auth_token
    replication_group_id     = module.test_ec_cluster.replication_group_id
  }
}
