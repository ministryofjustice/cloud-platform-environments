module "opensearch_snapshot_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.4.0"

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version      = "OpenSearch_2.9"
  snapshot_bucket_arn = module.opensearch_snapshot_bucket.bucket_arn

  cluster_config = {
    instance_count = 1
    instance_type  = "t2.micro.search"
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

# Output the proxy URL
resource "kubernetes_secret" "opensearch" {
  metadata {
    name      = "${var.team_name}-opensearch-proxy-url"
    namespace = var.namespace
  }

  data = {
    proxy_url = module.opensearch.proxy_url
  }
}
