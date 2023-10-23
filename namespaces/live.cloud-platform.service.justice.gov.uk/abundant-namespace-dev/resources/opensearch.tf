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
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=fix-auto-tune-syntax"

  auto_tune_config                = {
    desired_state                  = "ENABLED"
    start_at                       = "2023-10-01T21:00:00.00Z"
    duration_value                 = 8
    duration_unit                  = "HOURS"
    cron_expression_for_recurrence = "00 21 * * *"
    rollback_on_disable            = "NO_ROLLBACK"
  }
  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version      = "OpenSearch_2.9"
  snapshot_bucket_arn = module.opensearch_snapshot_bucket.bucket_arn

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
