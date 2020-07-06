module "probation_offender_search_es" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.1"
  cluster_name               = var.cluster_name
  cluster_state_bucket       = var.cluster_state_bucket
  application                = var.application
  business-unit              = var.business-unit
  environment-name           = var.environment-name
  infrastructure-support     = var.infrastructure-support
  is-production              = var.is-production
  team_name                  = var.team_name
  elasticsearch-domain       = "probation-search"
  namespace                  = var.namespace
  elasticsearch_version      = "7.4"
  aws-es-proxy-replica-count = 2
  instance_type              = "t2.medium.elasticsearch"
}
