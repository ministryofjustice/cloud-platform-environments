module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  providers = {
    aws = aws.london
  }

  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

resource "github_actions_environment_variable" "s3_bucket_name" {
  repository    = "onboarding-optimisation"
  environment   = "dev"
  variable_name = "S3_BUCKET_NAME"
  value         = module.s3_bucket.bucket_name
}
