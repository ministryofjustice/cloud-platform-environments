################################################################################
# Peoplefinder
# Application Elasticsearch cluster
#################################################################################

# Elastic search module
module "peoplefinder_es" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.9.5"
  cluster_name               = var.cluster_name
  application                = "peoplefinder"
  business-unit              = "Central Digital"
  environment-name           = "staging"
  infrastructure-support     = "people-finder-support@digital.justice.gov.uk"
  is-production              = "false"
  team_name                  = "peoplefinder"
  elasticsearch-domain       = "es"
  namespace                  = "peoplefinder-staging"
  elasticsearch_version      = "7.9"
  aws-es-proxy-replica-count = 1
  instance_type              = "t3.medium.elasticsearch"

  advanced_options = {
    override_main_response_version = true
  }
}
