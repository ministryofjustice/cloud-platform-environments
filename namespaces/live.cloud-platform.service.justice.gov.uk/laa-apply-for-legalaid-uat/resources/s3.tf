module "authorized-keys" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = "apply-for-legal-aid"
  acl                    = "private"
  business_unit          = "laa"
  application            = "laa-apply-for-legal-aid"
  is_production          = "false"
  environment_name       = "uat"
  infrastructure_support = "apply-for-civil-legal-aid@digital.justice.gov.uk"
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
    bucket_name = module.authorized-keys.bucket_name
  }
}
