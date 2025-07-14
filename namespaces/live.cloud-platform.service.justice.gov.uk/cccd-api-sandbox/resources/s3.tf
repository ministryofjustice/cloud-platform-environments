module "cccd_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = "laa-get-paid"
  business_unit          = "legal-aid-agency"
  application            = "cccd"
  is_production          = "false"
  environment_name       = "api-sandbox"
  infrastructure_support = "crowncourtdefence@digital.justice.gov.uk"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cccd_s3_bucket" {
  metadata {
    name      = "cccd-s3-bucket"
    namespace = "cccd-api-sandbox"
  }

  data = {
    bucket_arn  = module.cccd_s3_bucket.bucket_arn
    bucket_name = module.cccd_s3_bucket.bucket_name
  }
}
