# Configure an S3 bucket for Snapshot Management
module "s3_opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

# Create the domain
module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.4.0"

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version      = "OpenSearch_2.7"
  snapshot_bucket_arn = module.s3_opensearch.bucket_arn

  # These are the normal settings for staging.

  # Non-production cluster configuration
  cluster_config = {
    instance_count = 2
    instance_type  = "t3.small.search"
  }

  ebs_options = {
    volume_size = 10
  }

  # These are the settings to flex staging up to match production.
  # These should only be used when setting staging up for load testing, so it accurately
  # matches production and therefore is an accurate prediction of prod behaviour.

  # Production cluster configuration
#  cluster_config = {
#    instance_count = 3
#    instance_type  = "m6g.large.search"
#
#    # Dedicated primary nodes
#    dedicated_master_enabled = true
#    dedicated_master_count   = 3 # can only either be 3 or 5
#    dedicated_master_type    = "m6g.large.search"
#  }
#
#  ebs_options = {
#    volume_size = 100
#  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
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
