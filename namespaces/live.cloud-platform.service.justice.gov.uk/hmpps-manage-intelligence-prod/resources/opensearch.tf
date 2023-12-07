module "s3" {
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
  engine_version      = "OpenSearch_2.7"
  snapshot_bucket_arn = module.s3.bucket_arn

  cluster_config = {
    instance_count           = 3
    instance_type            = "r6g.large.search"
    dedicated_master_enabled = true
    dedicated_master_count   = 3
    dedicated_master_type    = "m6g.large.search"
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

resource "kubernetes_secret" "os_snapshots_role" {
  metadata {
    name      = "os-snapshot-role"
    namespace = var.namespace
  }

  data = {
    snapshot_role_arn = module.opensearch.snapshot_role_arn
  }
}

resource "kubernetes_secret" "os_snapshots" {
  metadata {
    name      = "os-snapshot-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3.bucket_arn
    bucket_name = module.s3.bucket_name
  }
}

# Output the proxy URL
resource "kubernetes_secret" "opensearch" {
  metadata {
    name      = "dps-opensearch-proxy-url"
    namespace = var.namespace
  }

  data = {
    proxy_url = module.opensearch.proxy_url
  }
}