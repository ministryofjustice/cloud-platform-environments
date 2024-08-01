module "s3_snapshot_bucket" {
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.5.1"

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version      = "OpenSearch_2.13"
  snapshot_bucket_arn = module.s3_snapshot_bucket.bucket_arn

  # Production like configuration.
  cluster_config = {
    instance_count           = 3
    instance_type            = "r6g.large.search"

    # Masters do not hold data, they perform other cluster tasks.
    dedicated_master_enabled = true
    dedicated_master_count   = 3
    dedicated_master_type    = "t2.medium.search"
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
    name      = "opensearch-output"
    namespace = var.namespace
  }

  data = {
    proxy_url = module.opensearch.proxy_url
  }
}
