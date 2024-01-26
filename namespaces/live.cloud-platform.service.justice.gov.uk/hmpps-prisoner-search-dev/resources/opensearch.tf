module "hmpps_prisoner_search_opensearch" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=switch_auto_tune"
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
    instance_type  = "t3.medium.search"
  }

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

resource "kubernetes_secret" "opensearch" {
  metadata {
    name      = "opensearch"
    namespace = var.namespace
  }

  data = {
    url = module.hmpps_prisoner_search_opensearch.proxy_url
  }
}
