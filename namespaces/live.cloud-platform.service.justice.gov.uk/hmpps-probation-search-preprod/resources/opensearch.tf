module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=switch_auto_tune"

  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
  vpc_name               = var.vpc_name

  engine_version      = "OpenSearch_2.7"
  snapshot_bucket_arn = module.opensearch_snapshot_bucket.bucket_arn
  cluster_config = {
    instance_count           = 6
    instance_type            = "m6g.xlarge.search"
    dedicated_master_enabled = true
    dedicated_master_count   = 3
    dedicated_master_type    = "m6g.large.search"
  }
  proxy_count = 3
  ebs_options = {
    volume_size = 368
    throughput  = 250
  }
}

module "opensearch_snapshot_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

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

resource "kubernetes_secret" "indexer_url" {
  metadata {
    name      = "person-search-index-from-delius-opensearch"
    namespace = "hmpps-probation-integration-services-${var.environment}"
  }
  data = {
    url = module.opensearch.proxy_url
  }
}
