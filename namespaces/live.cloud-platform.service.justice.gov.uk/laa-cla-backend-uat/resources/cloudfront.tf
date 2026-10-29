module "cloudfront_static_assets" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.6.0" # use the latest release

  # Configuration
  bucket_id          = module.cla_backend_static_files_bucket.bucket_name
  bucket_domain_name = module.cla_backend_static_files_bucket.bucket_domain_name

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


resource "kubernetes_secret" "cloudfront_static_assets_secrets" {
  metadata {
    name      = "cloudfront-static-assets"
    namespace = var.namespace
  }

  data = {
    cloudfront_url          = module.cloudfront_static_assets.cloudfront_url
  }
}