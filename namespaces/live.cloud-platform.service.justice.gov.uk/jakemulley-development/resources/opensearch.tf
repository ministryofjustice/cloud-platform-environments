module "opensearch_non_production" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.0.0"

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
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "opensearch" {
  metadata {
    name      = "${var.team_name}-opensearch-proxy-url"
    namespace = var.namespace
  }

  data = {
    proxy_url = module.opensearch_non_production.proxy_url
  }
}

module "opensearch_production" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.0.0" # use the latest release

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version = "OpenSearch_2.5"

  cluster_config   = {
    instance_count = 3
    instance_type  = "m6g.large.search"
  }

  ebs_options = {
    volume_size = 100
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

module "opensearch_production_huge" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.0.0" # use the latest release

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version = "OpenSearch_2.5"

  cluster_config   = {
    instance_count = 15
    instance_type  = "m6g.xlarge.search"
  }

  ebs_options = {
    volume_size = 100
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
