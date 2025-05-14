module "apex-migration-s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"

  # S3 configuration
  versioning = true

  # Tags
  business_unit          = var.business_unit
  application            = local.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
