module "documents_bucket" {
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
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyDocumentBucketAndObjectDeletion"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:DeleteBucket",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
        ]
        Resource = [
          "$${bucket_arn}",
          "$${bucket_arn}/*",
        ]
      }
    ]
  })
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
    name      = "ppud-object-storage"
    namespace = var.namespace
  }

  data = {
    AWS_S3_BUCKET_NAME = module.documents_bucket.bucket_name
    AWS_REGION         = "eu-west-2"
  }

  type = "Opaque"
}

# This identifier is reserved for the separately controlled preservation workflow.
# No production workload or loader role is granted access to this bucket.
resource "kubernetes_secret" "legacy_exports" {
  metadata {
    name      = "ppud-legacy-export-operations"
    namespace = var.namespace
  }

  data = {
    LEGACY_EXPORT_S3_BUCKET = module.legacy_exports_bucket.bucket_name
    AWS_REGION              = "eu-west-2"
  }

  type = "Opaque"
}
