module "raz_one_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.9.1"
  cluster_name           = var.cluster_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  elasticsearch-domain               = "es"
  elasticsearch_version              = "7.10"
  instance_type                      = "t2.medium.elasticsearch"
  log_publishing_application_enabled = false

  irsa_enabled          = "true"
  assume_enabled        = "false"
}
