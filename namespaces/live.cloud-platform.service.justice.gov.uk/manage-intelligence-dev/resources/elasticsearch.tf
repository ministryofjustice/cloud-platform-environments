module "manage_intelligence_elasticsearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.2.0"

  vpc_name                        = var.vpc_name
  eks_cluster_name                = var.eks_cluster_name
  application                     = var.application
  business-unit                   = var.business_unit
  environment-name                = var.environment
  infrastructure-support          = var.infrastructure_support
  is-production                   = var.is_production
  team_name                       = var.team_name
  elasticsearch-domain            = "manage-intelligence"
  namespace                       = var.namespace
  elasticsearch_version           = "7.10"
  aws-es-proxy-replica-count      = 2
  instance_type                   = "t3.medium.elasticsearch"
  instance_count                  = 4
  encryption_at_rest              = true
  node_to_node_encryption_enabled = true
  ebs_iops                        = 0
  ebs_volume_type                 = "gp2"
}
