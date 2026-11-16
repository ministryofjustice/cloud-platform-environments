module "documents_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  versioning = true
}

module "legacy_export_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  versioning = true
}

resource "kubernetes_secret" "document_bucket" {
  metadata {
    name      = "ppud-document-storage"
    namespace = var.namespace
  }

  data = {
    bucket_name = module.documents_bucket.bucket_name
    bucket_arn  = module.documents_bucket.bucket_arn
  }
}

resource "kubernetes_secret" "legacy_export_bucket" {
  metadata {
    name      = "ppud-legacy-export-storage"
    namespace = var.namespace
  }

  data = {
    bucket_name = module.legacy_export_bucket.bucket_name
    bucket_arn  = module.legacy_export_bucket.bucket_arn
  }
}
