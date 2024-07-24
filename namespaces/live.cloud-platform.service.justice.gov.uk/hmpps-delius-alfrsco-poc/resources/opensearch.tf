module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.5.0" # use the latest release

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version      = "OpenSearch_1.3"
  snapshot_bucket_arn = module.s3_opensearch_snapshots_bucket.bucket_arn
  # Non-production cluster configuration
  cluster_config = {
    instance_count = 2
    instance_type  = "m6g.large.search"
  }

  ebs_options = {
    volume_size = 50
  }

  advanced_options = {
    # increase the maxClauseCount to 4096
    "indices.query.bool.max_clause_count" = "4096"
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
    name      = "opensearch-proxy-url"
    namespace = var.namespace
  }

  data = {
    proxy_url = module.opensearch.proxy_url
  }
}
