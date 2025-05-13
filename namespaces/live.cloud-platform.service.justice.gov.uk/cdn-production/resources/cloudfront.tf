module "cloudfront" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.3.1"

  # Configuration
  bucket_id          = module.s3.bucket_name
  bucket_domain_name = module.s3.bucket_domain_name

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

# resource "kubernetes_secret" "cdn_cloudfront" {
#   metadata {
#     name      = "cdn-cloudfront"
#     namespace = var.namespace
#   }

#   data = {
#     cloudfront_url = module.s3.cloudfront_url
#   }
# }
