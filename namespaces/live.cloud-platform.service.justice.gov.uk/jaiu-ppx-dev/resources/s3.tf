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

module "legacy_exports_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  versioning                    = true
  enable_allow_block_pub_access = true
  lifecycle_rule                = []
}

resource "kubernetes_secret" "object_storage" {
  metadata {
    name      = "ppx-object-storage"
    namespace = var.namespace
  }

  data = {
    AWS_S3_BUCKET_NAME = module.documents_bucket.bucket_name
    AWS_REGION         = "eu-west-2"
  }

  type = "Opaque"
}

# Mirrors jaiu-ppx-prod. No workload or loader role is granted access to this bucket.
resource "kubernetes_secret" "legacy_exports" {
  metadata {
    name      = "ppx-legacy-export-operations"
    namespace = var.namespace
  }

  data = {
    LEGACY_EXPORT_S3_BUCKET = module.legacy_exports_bucket.bucket_name
    AWS_REGION              = "eu-west-2"
  }

  type = "Opaque"
}
