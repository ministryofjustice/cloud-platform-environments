################################################################################
# Peoplefinder
# Application Elasticsearch cluster
#################################################################################

module "peoplefinder_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.9.5"
  cluster_name           = var.cluster_name
  application            = "peoplefinder"
  business-unit          = "Central Digital"
  environment-name       = "demo"
  infrastructure-support = "people-finder-support@digital.justice.gov.uk"
  is-production          = "false"
  team_name              = "peoplefinder"
  elasticsearch-domain   = "es"
  namespace              = "peoplefinder-demo"
  elasticsearch_version  = "7.9"
  instance_type          = "t2.small.elasticsearch"

  advanced_options = {
    override_main_response_version = true
  }
}
