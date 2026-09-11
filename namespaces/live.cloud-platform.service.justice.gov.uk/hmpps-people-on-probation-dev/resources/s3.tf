# Documents feature: stores uploaded court order PDFs (and, in future, other document types -
# Only the API talks to this bucket directly (IRSA below, granted to its service account) - it owns CRN-based
# authorization and mints all presigned URLs. The browser then PUTs/GETs the PDF bytes
# directly against those presigned URLs, which is why CORS below allows this UI's own
# origin(s) rather than the API's.
#

module "hmpps_people_on_probation_documents_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  versioning = true

  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = [
        "https://probation-account-dev.hmpps.service.justice.gov.uk",
        "http://localhost:3000",
      ]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  providers = { aws = aws.london }
}

resource "kubernetes_secret" "hmpps_people_on_probation_documents_s3_bucket" {
  metadata {
    name      = "hmpps-people-on-probation-documents-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps_people_on_probation_documents_s3_bucket.bucket_arn
    bucket_name = module.hmpps_people_on_probation_documents_s3_bucket.bucket_name
  }
}
