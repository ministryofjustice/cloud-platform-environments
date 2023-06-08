module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.1.0" # use the latest release

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version = "OpenSearch_2.5"

  cluster_config = {
    # Dedicated primary nodes
    dedicated_master_count   = 3
    dedicated_master_enabled = true
    dedicated_master_type    = "m6g.large.search"
    # Instances
    instance_count = 3
    instance_type  = "m6g.large.search"
    # Warm storage
    warm_count   = 3
    warm_enabled = true
    warm_type    = "ultrawarm1.medium.search"
    # Cold storage
    cold_enabled = true
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
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}