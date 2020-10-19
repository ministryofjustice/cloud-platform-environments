################################################################################
# Track a Query (Correspondence Tool Staff)
# S3 Bucket for file uploads
#################################################################################

module "track_a_query_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"

  team_name              = "correspondence"
  business-unit          = "Central Digital"
  application            = "track-a-query"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "mohammed.seedat@digital.justice.gov.uk"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "track_a_query_s3" {
  metadata {
    name      = "track-a-query-s3-output"
    namespace = "cts-prototype-dev-poc"
  }

  data = {
    access_key_id     = module.track_a_query_s3.access_key_id
    secret_access_key = module.track_a_query_s3.secret_access_key
    bucket_arn        = module.track_a_query_s3.bucket_arn
    bucket_name       = module.track_a_query_s3.bucket_name
  }
}

