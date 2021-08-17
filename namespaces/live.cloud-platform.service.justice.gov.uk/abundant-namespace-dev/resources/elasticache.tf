/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_team_ec_cluster" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=5.3"
  cluster_name           = var.cluster_name
  team_name              = "webops"
  namespace              = "abundant-namespace-dev"
  business-unit          = "HQ"
  application            = "cloud-p-test"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "platforms@digtal.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_team_ec_cluster" {
  metadata {
    name      = "example-team-ec-cluster-output"
    namespace = "abundant-namespace-dev"
  }

  data = {
    primary_endpoint_address = module.example_team_ec_cluster.primary_endpoint_address
    member_clusters          = jsonencode(module.example_team_ec_cluster.member_clusters)
    auth_token               = module.example_team_ec_cluster.auth_token
  }
}
