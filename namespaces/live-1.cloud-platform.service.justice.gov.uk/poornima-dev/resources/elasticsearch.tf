################################################################################
# Cloud Platform
# CP Test Elasticsearch cluster
#################################################################################

module "test_es_1" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=fix-resource-expression"
  cluster_name              = var.cluster_name
  cluster_state_bucket      = var.cluster_state_bucket
  application               = "cloud-platform-esupg"
  business-unit             = "Platforms"
  environment-name          = "dev"
  infrastructure-support    = "platforms@digital.justice.gov.uk"
  is-production             = "false"
  team_name                 = "webops"
  elasticsearch-domain      = "es-1"
  namespace                 = var.namespace
  elasticsearch_version     = "6.8"
  aws_es_proxy_service_name = "aws-es-proxy-es-1"
  s3_manual_snapshot_repository = module.es_snapshots_s3_bucket.bucket_arn
}


module "ns_annotation" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-ns-annotation?ref=0.0.2"
  ns_annotation_roles = [module.test_es_1.aws_iam_role_name]
  namespace           = var.namespace
}

module "es_snapshots_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.6"
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

