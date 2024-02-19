module "hmpps_prisoner_search_opensearch" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.5.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
  vpc_name               = var.vpc_name

  engine_version = "OpenSearch_2.9"

  cluster_config = {
    instance_count = 2
    instance_type  = "m6g.large.search"
  }

  ebs_options = {
    volume_size = 20
  }

  auto_tune_config = {
    start_at                       = "2100-10-23T20:00:00.00Z"
    duration_value                 = 10
    duration_unit                  = "HOURS"
    cron_expression_for_recurrence = ""
    rollback_on_disable            = "NO_ROLLBACK"
  }

  snapshot_bucket_arn = data.aws_s3_bucket.snapshot_bucket.arn
}

data "aws_s3_bucket" "snapshot_bucket" {
  bucket = "cloud-platform-852450f884768027e7dbe48002e188aa"
}

resource "kubernetes_secret" "os_snapshots_role" {
  metadata {
    name      = "os-snapshot-role"
    namespace = var.namespace
  }

  data = {
    snapshot_role_arn = module.hmpps_prisoner_search_opensearch.snapshot_role_arn
  }
}

resource "kubernetes_secret" "opensearch" {
  metadata {
    name      = "opensearch"
    namespace = var.namespace
  }

  data = {
    url = module.hmpps_prisoner_search_opensearch.proxy_url
  }
}
