module "prisoner_offender_search_elasticsearch" {
  source                          = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.4.0"
  vpc_name                        = var.vpc_name
  eks_cluster_name                = var.eks_cluster_name
  application                     = var.application
  business_unit                   = var.business_unit
  environment_name                = var.environment
  infrastructure_support          = var.infrastructure_support
  is_production                   = var.is_production
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
  s3_manual_snapshot_repository   = module.es_snapshots_s3_bucket.bucket_arn
  ebs_iops                        = 0
  ebs_volume_type                 = "gp2"
}

module "es_snapshots_s3_bucket" {
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

resource "kubernetes_secret" "es_snapshots_role" {
  metadata {
    name      = "es-snapshot-role"
    namespace = var.namespace
  }

  data = {
    snapshot_role_arn = module.prisoner_offender_search_elasticsearch.snapshot_role_arn
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

resource "kubernetes_secret" "es_snapshots_preprod" {
  metadata {
    name      = "es-snapshot-bucket"
    namespace = "prisoner-offender-search-preprod"
  }

  data = {
    bucket_arn  = module.es_snapshots_s3_bucket.bucket_arn
    bucket_name = module.es_snapshots_s3_bucket.bucket_name
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
