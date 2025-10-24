module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0" # use the latest release

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

# Create the domain
module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.8.1" # use the latest release

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version      = "OpenSearch_3.1"
  snapshot_bucket_arn = module.s3.bucket_arn

  # Non-production cluster configuration
  cluster_config = {
    instance_count = 2
    instance_type  = "t3.small.search"
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

resource "kubernetes_secret" "s3_bucket_name" {
  metadata {
    name      = "${var.team_name}-s3-bucket-name"
    namespace = var.namespace
  }

  data = {
    bucket_name = module.s3.bucket_name
  }
}