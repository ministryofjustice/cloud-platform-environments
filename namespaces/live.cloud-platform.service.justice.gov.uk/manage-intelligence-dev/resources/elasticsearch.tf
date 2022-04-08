module "manage_intelligence_elasticsearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.9.3"

  cluster_name                    = var.cluster_name
  application                     = var.application
  business-unit                   = var.business-unit
  environment-name                = var.environment-name
  infrastructure-support          = var.infrastructure-support
  is-production                   = var.is-production
  team_name                       = var.team_name
  elasticsearch-domain            = "manage-intelligence"
  namespace                       = var.namespace
  elasticsearch_version           = "7.10"
  aws-es-proxy-replica-count      = 2
  instance_type                   = "t3.medium.elasticsearch"
  instance_count                  = 4
  encryption_at_rest              = true
  node_to_node_encryption_enabled = true
}
