module "jacksapp_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.2.0"
  eks_cluster_name       = var.eks_cluster_name
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  elasticsearch-domain            = "jacksapp-es"
  encryption_at_rest              = true
  node_to_node_encryption_enabled = true
  domain_endpoint_enforce_https   = true

  # change the elasticsearch version as you see fit.
  elasticsearch_version = "7.10"

  instance_count           = 3
  instance_type            = "t3.medium"
  zone_awareness_enabled   = "true"
  availability_zone_count  = 3
  ebs_volume_size          = 10
  ebs_volume_type          = "gp3"
  ebs_iops                 = 3000
  dedicated_master_enabled = "true"
  dedicated_master_type    = "t3.medium"
  warm_enabled             = "true"
  cold_enabled             = "true"
  timestamp_field          = "last_updated"
  index_pattern            = "kibana_sample_data_logs*"
}