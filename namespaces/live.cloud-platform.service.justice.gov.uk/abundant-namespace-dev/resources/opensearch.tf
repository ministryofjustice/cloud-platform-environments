# module "opensearch_snapshot_bucket" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"

#   team_name              = var.team_name
#   business-unit          = var.business_unit
#   application            = var.application
#   is-production          = var.is_production
#   environment-name       = var.environment
#   infrastructure-support = var.infrastructure_support
#   namespace              = var.namespace
# }

module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=main"

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version      = "OpenSearch_2.5"
  # snapshot_bucket_arn = module.opensearch_snapshot_bucket.bucket_arn

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
