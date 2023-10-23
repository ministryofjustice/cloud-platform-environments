module "cccd_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = "laa-get-paid"
  business_unit          = "legal-aid-agency"
  application            = "cccd"
  is_production          = "false"
  environment_name       = "dev"
  infrastructure_support = "crowncourtdefence@digital.justice.gov.uk"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cccd_s3_bucket" {
  metadata {
    name      = "cccd-s3-bucket"
    namespace = "cccd-dev-lgfs"
  }

  data = {
    bucket_arn  = module.cccd_s3_bucket.bucket_arn
    bucket_name = module.cccd_s3_bucket.bucket_name
  }
}
