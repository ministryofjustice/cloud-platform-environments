module "cloudfront" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.0.0"

  # Configuration
  bucket_id          = module.s3_bucket.bucket_name
  bucket_domain_name = "${module.s3_bucket.bucket_name}.s3.eu-west-2.amazonaws.com"

  origin = {
    origin_path = "/www.justice.gov.uk/2023-07-28-03-00/"
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
