module "cloudfront" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront-edits?ref=cloudfront-functions-draft"

  # Configuration
  bucket_id            = module.s3_bucket.bucket_name
  bucket_domain_name   = "${module.s3_bucket.bucket_name}.s3.eu-west-2.amazonaws.com"
  # aliases              = [var.cloudfront_alias]
  # aliases_cert_arn     = aws_acm_certificate.cloudfront_alias_cert.arn
  trusted_public_keys  = var.trusted_public_keys

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
    cloudfront_alias       = var.cloudfront_alias
    cloudfront_url         = module.cloudfront.cloudfront_url
    cloudfront_public_keys = module.cloudfront.cloudfront_public_keys
  }
} 
