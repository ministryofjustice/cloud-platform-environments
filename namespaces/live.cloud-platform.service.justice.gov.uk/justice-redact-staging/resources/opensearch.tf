module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.8.1" # check releases page for latest tag

  # VPC/EKS configuration
  vpc_name         = var.vpc_name         # value = "live" - add to terraform.tfvars
  eks_cluster_name = var.eks_cluster_name # defaults to "live"

  # Cluster configuration
  engine_version      = "OpenSearch_3.1"
  snapshot_bucket_arn = module.s3_bucket.bucket_arn

  cluster_config = {
    instance_count = 2
    instance_type  = "t3.small.search"
  }

  ebs_options = {
    volume_size = 10
  }

  # Tags
  business_unit           = var.business_unit
  application              = var.application
  is_production            = var.is_production
  team_name                = var.team_name
  namespace                = var.namespace
  environment_name         = var.environment
  infrastructure_support   = var.infrastructure_support
}

resource "kubernetes_secret" "opensearch" {
  metadata {
    name      = "${var.team_name}-opensearch-proxy-url"
    namespace = var.namespace
  }

  data = {
    domain_name = module.opensearch.domain_name
    domain_arn  = module.opensearch.domain_arn
    endpoint    = module.opensearch.endpoint  # VPC endpoint - not reachable directly from outside the VPC
    proxy_url   = module.opensearch.proxy_url # use this from your app - routes through the in-cluster proxy service
  }
}
