module "hmpps_prisoner_search_opensearch" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
  vpc_name               = var.vpc_name

  engine_version = "OpenSearch_2.5"

  cluster_config = {
    instance_count = 2
    instance_type  = "t3.small.search"
  }

  ebs_options = {
    volume_size = 10
  }
}

#module "os_snapshots_s3_bucket" {
#  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
#  team_name              = var.team_name
#  acl                    = "private"
#  versioning             = false
#  business-unit          = var.business_unit
#  application            = var.application
#  is-production          = var.is_production
#  environment-name       = var.environment-name
#  infrastructure-support = var.infrastructure_support
#  namespace              = var.namespace
#
#  providers = {
#    aws = aws.london
#  }
#}
#
#resource "kubernetes_secret" "os_snapshots_role" {
#  metadata {
#    name      = "es-snapshot-role"
#    namespace = var.namespace
#  }
#
#  data = {
#    snapshot_role_arn = module.hmpps_prisoner_search_opensearch.snapshot_role_arn
#  }
#}
#
#resource "kubernetes_secret" "os_snapshots" {
#  metadata {
#    name      = "os-snapshot-bucket"
#    namespace = var.namespace
#  }
#
#  data = {
#    bucket_arn  = module.os_snapshots_s3_bucket.bucket_arn
#    bucket_name = module.os_snapshots_s3_bucket.bucket_name
#  }
#}

resource "kubernetes_secret" "opensearch" {
  metadata {
    name      = "opensearch"
    namespace = var.namespace
  }

  data = {
    aws_es_proxy_url = module.hmpps_prisoner_search_opensearch.proxy_url
  }
}
