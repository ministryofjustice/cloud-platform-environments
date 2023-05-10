module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.0.0"

  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
  vpc_name               = var.vpc_name

  engine_version = "OpenSearch_2.5"
  cluster_config = {
    instance_count = 2
    instance_type  = "t3.medium.search"
  }
  proxy_count = 2
  ebs_options = {
    volume_size = 30
  }
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

locals {
  # Temporarily rewriting the URL to enable access across namespaces until the full URL is outputted directly from the module.
  # See https://github.com/ministryofjustice/cloud-platform-terraform-opensearch/pull/3
  proxy_url_without_port        = regex("(.*):9200", module.opensearch.proxy_url)[0]
  proxy_url_with_cluster_suffix = "${local.proxy_url_without_port}.${var.namespace}.svc.cluster.local:9200"
}

resource "kubernetes_secret" "indexer_url" {
  metadata {
    name      = "person-search-index-from-delius-opensearch"
    namespace = "hmpps-probation-integration-services-${var.environment}"
  }
  data = {
    url = local.proxy_url_with_cluster_suffix
  }
}