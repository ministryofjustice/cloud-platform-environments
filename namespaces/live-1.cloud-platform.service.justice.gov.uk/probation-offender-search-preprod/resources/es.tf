module "probation_offender_search_es" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.5.1"
  cluster_name                  = var.cluster_name
  cluster_state_bucket          = var.cluster_state_bucket
  application                   = var.application
  business-unit                 = var.business-unit
  environment-name              = var.environment-name
  infrastructure-support        = var.infrastructure-support
  is-production                 = var.is-production
  team_name                     = var.team_name
  elasticsearch-domain          = "probation-search"
  namespace                     = var.namespace
  elasticsearch_version         = "7.9"
  aws-es-proxy-replica-count    = 4
  instance_type                 = "t2.medium.elasticsearch"
  ebs_volume_size               = 15
  s3_manual_snapshot_repository = data.aws_s3_bucket.snapshot_bucket.arn
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
    snapshot_role_arn = module.probation_offender_search_es.snapshot_role_arn
  }
}
