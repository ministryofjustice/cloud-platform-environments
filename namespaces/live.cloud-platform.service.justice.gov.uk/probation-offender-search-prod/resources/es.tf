module "probation_offender_search_elasticsearch" {
  source                          = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=upd-docs"
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
  instance_type                   = "m5.large.elasticsearch"
  ebs_volume_size                 = 15
  s3_manual_snapshot_repository   = module.es_snapshots_s3_bucket.bucket_arn
}

module "es_snapshots_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7.1"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
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

resource "kubernetes_secret" "es_snapshots" {
  metadata {
    name      = "es-snapshot-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.es_snapshots_s3_bucket.bucket_arn
    bucket_name = module.es_snapshots_s3_bucket.bucket_name
  }
}

resource "kubernetes_secret" "es_snapshots_staging" {
  metadata {
    name      = "es-snapshot-bucket"
    namespace = "probation-offender-search-staging"
  }

  data = {
    bucket_arn  = module.es_snapshots_s3_bucket.bucket_arn
    bucket_name = module.es_snapshots_s3_bucket.bucket_name
  }
}

resource "kubernetes_secret" "es_snapshots_preprod" {
  metadata {
    name      = "es-snapshot-bucket"
    namespace = "probation-offender-search-preprod"
  }

  data = {
    bucket_arn  = module.es_snapshots_s3_bucket.bucket_arn
    bucket_name = module.es_snapshots_s3_bucket.bucket_name
  }
}

