################################################################################
# Cloud Platform
# CP Test Elasticsearch cluster
#################################################################################

module "peoplefinder_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.5.1"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  application            = "cloud-platform-esupg"
  business-unit          = "Platforms"
  environment-name       = "dev"
  infrastructure-support = "platforms@digital.justice.gov.uk"
  is-production          = "false"
  team_name              = "webops"
  elasticsearch-domain   = "es"
  namespace              = "poornima-dev"
  elasticsearch_version  = "6.8"
}
