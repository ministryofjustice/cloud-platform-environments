################################################################################
# Peoplefinder
# Application Elasticsearch cluster
#################################################################################

module "peoplefinder_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.1"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  application            = "peoplefinder"
  business-unit          = "Central Digital"
  environment-name       = "production"
  infrastructure-support = "people-finder-support@digital.justice.gov.uk"
  is-production          = "true"
  team_name              = "peoplefinder"
  elasticsearch-domain   = "es"
  namespace              = "peoplefinder-production"
  elasticsearch_version  = "6.8"
}
