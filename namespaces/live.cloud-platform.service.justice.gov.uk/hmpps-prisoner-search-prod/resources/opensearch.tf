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
    instance_count = 6 # should always a multiple of 3, to split nodes evenly across three availability zones
    instance_type  = "m6g.xlarge.search"

    # Dedicated primary nodes
    dedicated_master_enabled = true
    dedicated_master_count   = 3 # can only either be 3 or 5
    dedicated_master_type    = "m6g.large.search"
  }

  auto_tune_config = {
    desired_state                  = "ENABLED"
    start_at                       = "2100-10-23T20:00:00.00Z"
    duration_value                 = 10
    duration_unit                  = "HOURS"
    cron_expression_for_recurrence = ""
    rollback_on_disable            = "NO_ROLLBACK"
  }

  proxy_count = 3

  ebs_options = {
    volume_size = 20
  }
  snapshot_bucket_arn = module.os_snapshots_s3_bucket.bucket_arn
}

module "os_snapshots_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
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

resource "kubernetes_secret" "os_snapshots" {
  metadata {
    name      = "os-snapshot-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.os_snapshots_s3_bucket.bucket_arn
    bucket_name = module.os_snapshots_s3_bucket.bucket_name
  }
}

resource "kubernetes_secret" "os_snapshots_preprod" {
  metadata {
    name      = "os-snapshot-bucket"
    namespace = "hmpps-prisoner-search-preprod"
  }

  data = {
    bucket_arn  = module.os_snapshots_s3_bucket.bucket_arn
    bucket_name = module.os_snapshots_s3_bucket.bucket_name
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
