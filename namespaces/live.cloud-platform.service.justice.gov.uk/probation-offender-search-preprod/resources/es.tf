module "probation_offender_search_elasticsearch" {
  source                          = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.9.5"
  cluster_name                    = var.cluster_name
  application                     = var.application
  business-unit                   = var.business-unit
  environment-name                = var.environment-name
  infrastructure-support          = var.infrastructure-support
  is-production                   = var.is-production
  team_name                       = var.team_name
  elasticsearch-domain            = "search-probation"
  aws_es_proxy_service_name       = "es-proxy"
  encryption_at_rest              = true
  node_to_node_encryption_enabled = true
  namespace                       = var.namespace
  elasticsearch_version           = "7.9"
  aws-es-proxy-replica-count      = 4
  instance_type                   = "t3.medium.elasticsearch"
  ebs_volume_size                 = 15
  s3_manual_snapshot_repository   = data.aws_s3_bucket.snapshot_bucket.arn
}

data "aws_s3_bucket" "snapshot_bucket" {
  bucket = "cloud-platform-b98efe046f8e2974726adda74c50890e"
}

resource "kubernetes_secret" "es_snapshots_role" {
  metadata {
    name      = "es-snapshot-role"
    namespace = var.namespace
  }

  data = {
    snapshot_role_arn = module.probation_offender_search_elasticsearch.snapshot_role_arn
  }
}
