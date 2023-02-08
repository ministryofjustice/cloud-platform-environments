module "test_ec_cluster" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.6"

  // The first two inputs are provided by the pipeline for cloud-platform. See the example for more detail.
  vpc_name               = var.vpc_name
  team_name              = "webops"
  business-unit          = "platforms"
  application            = "testapp"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "platforms@digtal.justice.gov.uk"
  namespace              = var.namespace
  node_type              = "cache.t2.small"
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  providers = {
    aws = aws.london
  }
}


resource "kubernetes_secret" "test_ec_cluster" {
  metadata {
    name      = "test-ec-cluster-output"
    namespace              = var.namespace
  }

  data = {
    primary_endpoint_address = module.test_ec_cluster.primary_endpoint_address
    member_clusters          = jsonencode(module.test_ec_cluster.member_clusters)
    auth_token               = module.test_ec_cluster.auth_token
  }
}