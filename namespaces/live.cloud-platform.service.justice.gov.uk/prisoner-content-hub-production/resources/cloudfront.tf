module "cloudfront" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=s3-policy"

  # Configuration
  bucket_id                    = module.drupal_content_storage_2.bucket_name
  bucket_domain_name           = module.drupal_content_storage_2.bucket_domain_name
  ip_allow_listing_environment = var.environment-name
  attach_bucket_policy         = false

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  service_area           = var.service_area
}
