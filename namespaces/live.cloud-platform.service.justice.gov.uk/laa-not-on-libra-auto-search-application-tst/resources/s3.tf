module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=version" # use the latest release

  # S3 configuration
  versioning = true

  # Tags
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  # This is a new input.
  providers = {
    aws = aws.london
  }
}
