module "prisoner_offender_search_elasticsearch" {
  source                          = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.2.0"
  vpc_name                        = var.vpc_name
  eks_cluster_name                = var.eks_cluster_name
  application                     = var.application
  business-unit                   = var.business_unit
  environment-name                = var.environment
  infrastructure-support          = var.infrastructure_support
  is-production                   = var.is_production
  team_name                       = var.team_name
  elasticsearch-domain            = "search-prisoner"
  aws_es_proxy_service_name       = "es-proxy"
  encryption_at_rest              = true
  node_to_node_encryption_enabled = true
  domain_endpoint_enforce_https   = true
  namespace                       = var.namespace
  elasticsearch_version           = "7.10"
  aws-es-proxy-replica-count      = 4
  instance_count                  = 6
  instance_type                   = "m6g.xlarge.elasticsearch"
  s3_manual_snapshot_repository   = data.aws_s3_bucket.snapshot_bucket.arn
  ebs_iops                        = 0
  ebs_volume_type                 = "gp2"
}


data "aws_s3_bucket" "snapshot_bucket" {
  bucket = "cloud-platform-915f65c9849654f480afa21d9e389bd7"
}

resource "kubernetes_secret" "es_snapshots_role" {
  metadata {
    name      = "es-snapshot-role"
    namespace = var.namespace
  }

  data = {
    snapshot_role_arn = module.prisoner_offender_search_elasticsearch.snapshot_role_arn
  }
}

resource "kubernetes_secret" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = var.namespace
  }

  data = {
    aws_es_proxy_url = module.prisoner_offender_search_elasticsearch.aws_es_proxy_url
  }
}
