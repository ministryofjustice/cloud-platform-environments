module "cloudfront" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.2.0"

  # Configuration
  bucket_id           = module.s3_bucket.bucket_name
  bucket_domain_name  = "${module.s3_bucket.bucket_name}.s3.eu-west-2.amazonaws.com"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "cloudfront_url" {
  metadata {
    name      = "cloudfront-output"
    namespace = var.namespace
  }

  data = {
    cloudfront_url = module.cloudfront.cloudfront_url
  }
}
