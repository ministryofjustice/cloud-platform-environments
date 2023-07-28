module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=jakemulley-patch-1"

  # Tags
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
}

module "cloudfront" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=initial" # use the latest release

  # Configuration
  bucket_domain_name = module.s3.bucket_domain_name
  bucket_id = module.s3.bucket_name

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
