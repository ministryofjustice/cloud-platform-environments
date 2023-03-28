module "rotate_token_ec_cluster" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"

  # The first two inputs are provided by the pipeline for cloud-platform. See the example for more detail.
  vpc_name               = var.vpc_name
  team_name              = "webops"
  business-unit          = "platforms"
  application            = "rotatetokenapp"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "platforms@digtal.justice.gov.uk"
  namespace              = var.namespace
  providers = {
    aws = aws.london
  }
}


resource "kubernetes_secret" "rotate_token_ec_cluster" {
  metadata {
    name      = "rotate-token-ec-cluster-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.rotate_token_ec_cluster.primary_endpoint_address
    member_clusters          = jsonencode(module.rotate_token_ec_cluster.member_clusters)
    auth_token               = module.rotate_token_ec_cluster.auth_token
  }
}
