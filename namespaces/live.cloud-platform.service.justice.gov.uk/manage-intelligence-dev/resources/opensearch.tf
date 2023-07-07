module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.1.0" # use the latest release

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version = "OpenSearch_2.5"

  cluster_config   = {
    instance_count = 2
    instance_type  = "t3.medium.search"
  }

  ebs_options = {
    volume_size = 10
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}


module "manage_intelligence_elasticsearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.2.0"

  vpc_name                        = var.vpc_name
  eks_cluster_name                = var.eks_cluster_name
  application                     = var.application
  business-unit                   = var.business_unit
  environment-name                = var.environment-name
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
