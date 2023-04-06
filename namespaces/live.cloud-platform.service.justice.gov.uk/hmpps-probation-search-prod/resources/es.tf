module "probation_search_elasticsearch" {
  source                          = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.2.0"
  vpc_name                        = var.vpc_name
  eks_cluster_name                = var.eks_cluster_name
  application                     = var.application
  business-unit                   = var.business_unit
  environment-name                = var.environment
  infrastructure-support          = var.infrastructure_support
  is-production                   = var.is_production
  team_name                       = "pi"
  elasticsearch-domain            = "probation-search"
  aws_es_proxy_service_name       = "es-proxy"
  encryption_at_rest              = true
  node_to_node_encryption_enabled = true
  domain_endpoint_enforce_https   = true
  namespace                       = var.namespace
  elasticsearch_version           = "7.10"
  aws-es-proxy-replica-count      = 3
  dedicated_master_enabled        = true
  dedicated_master_count          = 3
  dedicated_master_type           = "m6g.large.elasticsearch"
  instance_count                  = 12
  instance_type                   = "m6g.xlarge.elasticsearch"
  ebs_volume_size                 = 128
}

