module "s3-probation-accounts" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1" # use the latest release

  # S3 configuration

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "s3-probation-accounts" {
  metadata {
    name      = "s3-probation-accounts-output"
    namespace = var.namespace
  }

  data = {
    probation_accounts_bucket_arn  = module.s3-probation-accounts.bucket_arn
    probation_accounts_bucket_name = module.s3-probation-accounts.bucket_name
  }
}