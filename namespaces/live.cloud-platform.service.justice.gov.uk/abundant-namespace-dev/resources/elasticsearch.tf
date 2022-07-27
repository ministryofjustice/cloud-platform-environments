
/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_team_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.9.5"
  cluster_name           = var.cluster_name
  application            = "testApp"
  business-unit          = "HQ"
  environment-name       = "dev"
  infrastructure-support = "cloud-platform@digital.justice.gov.uk"
  is-production          = "false"
  team_name              = "webops"
  elasticsearch-domain   = "cloud-p-test"
  namespace              = "abundant-namespace-dev"
  instance_type          = "t3.medium.elasticsearch"

  # change the elasticsearch version as you see fit.
  elasticsearch_version = "7.1"
}
