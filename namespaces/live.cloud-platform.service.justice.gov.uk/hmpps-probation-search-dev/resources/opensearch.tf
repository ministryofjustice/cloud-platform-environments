module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.0.0"

  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
  vpc_name               = var.vpc_name

  engine_version = "OpenSearch_2.5"
  cluster_config = {
    instance_count = 2
    instance_type  = "t3.medium.search"
  }
  proxy_count = 2
  ebs_options = {
    volume_size = 30
  }
}

