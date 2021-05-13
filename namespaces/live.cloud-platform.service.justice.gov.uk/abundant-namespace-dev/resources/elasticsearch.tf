module "example_team_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.8.2"
  cluster_name           = var.cluster_name
  application            = "testApp"
  business-unit          = "HQ"
  environment-name       = "dev"
  infrastructure-support = "cloud-platform@digital.justice.gov.uk"
  is-production          = "false"
  team_name              = "webops"
  elasticsearch-domain   = "cp-live-test"
  namespace              = "abundant-namespace-dev"

  # change the elasticsearch version as you see fit.
  elasticsearch_version = "7.1"
}

