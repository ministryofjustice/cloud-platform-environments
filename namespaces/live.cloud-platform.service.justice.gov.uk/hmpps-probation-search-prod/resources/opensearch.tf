module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.8.1"

  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
  vpc_name               = var.vpc_name

  engine_version      = "OpenSearch_3.1"
  auto_software_update_enabled = true

  snapshot_bucket_arn = module.opensearch_snapshot_bucket.bucket_arn
  cluster_config = {
    instance_count           = 6
    instance_type            = "m7g.xlarge.search"
    dedicated_master_enabled = true
    dedicated_master_count   = 3
    dedicated_master_type    = "m7g.large.search"
  }
  proxy_count = 3
  ebs_options = {
    volume_size = 600 # we can reduce this to 300GB after removing keyword search
    iops        = 10000
    throughput  = 1000
  }
}

module "opensearch_snapshot_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "probation_search_url" {
  metadata {
    name      = "opensearch"
    namespace = var.namespace
  }
  data = {
    url = module.opensearch.proxy_url
  }
}

resource "kubernetes_secret" "indexer_secret" {
  metadata {
    name      = "person-search-index-from-delius-opensearch"
    namespace = "hmpps-probation-integration-services-${var.environment}"
  }
  data = {
    url                                 = module.opensearch.proxy_url
    connector_role_arn                  = aws_iam_role.sagemaker_role.arn
    connector_external_account_role_arn = local.remote_sagemaker_role
  }
}
