module "authorized-keys" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.3"

  team_name              = "cloudplatform"
  business-unit          = "mojdigital"
  application            = "cloud-platform-authorized-keys"
  is-production          = "true"
  environment-name       = "production"
  infrastructure-support = "platforms@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "s3_bucket_credentials" {
  metadata {
    name      = "s3-bucket-authorized-keys"
    namespace = "authorized-keys-provider"
  }

  data = {
    bucket_name       = module.authorized-keys.bucket_name
    access_key_id     = module.authorized-keys.access_key_id
    bucket_arn        = module.authorized-keys.bucket_arn
    secret_access_key = module.authorized-keys.secret_access_key
  }
}

