module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.6"
  acl    = "private"

  team_name              = "apply-for-legal-aid"
  business-unit          = "laa"
  application            = "laa-apply-for-legal-aid"
  is-production          = "false"
  environment-name       = "uat"
  infrastructure-support = "apply@digital.justice.gov.uk"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "apply-for-legal-aid-s3-credentials" {
  metadata {
    name      = "apply-for-legal-aid-s3-instance-output"
    namespace = "laa-apply-for-legalaid-uat"
  }

  data = {
    bucket_name       = module.s3_bucket.bucket_name
    access_key_id     = module.s3_bucket.access_key_id
    secret_access_key = module.s3_bucket.secret_access_key
  }
}
