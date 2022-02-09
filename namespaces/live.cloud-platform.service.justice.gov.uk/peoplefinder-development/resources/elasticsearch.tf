################################################################################
# Peoplefinder
# Application Elasticsearch cluster
#################################################################################

# Elastic search module
module "peoplefinder_es" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.9.2"
  cluster_name               = var.cluster_name
  application                = "peoplefinder"
  business-unit              = "Central Digital"
  environment-name           = "development"
  infrastructure-support     = "people-finder-support@digital.justice.gov.uk"
  is-production              = "false"
  team_name                  = "peoplefinder"
  elasticsearch-domain       = "es"
  namespace                  = "peoplefinder-development"
  elasticsearch_version      = "7.9"
  aws-es-proxy-replica-count = 2
  instance_type              = "t3.medium.elasticsearch"

  irsa_enabled   = true
  assume_enabled = false
}

module "ns_annotation" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-ns-annotation?ref=0.0.3"
  ns_annotation_roles = [module.peoplefinder_es.aws_iam_role_name]
  namespace           = var.namespace
}