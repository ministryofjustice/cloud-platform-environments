module "cloudfront" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.2.0"

  # Configuration
  bucket_id                     = module.drupal_content_storage_2.bucket_name
  bucket_domain_name            = module.drupal_content_storage_2.bucket_domain_name
  ip_allow_listing_environment  = var.environment-name

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}
