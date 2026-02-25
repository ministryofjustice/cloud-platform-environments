module "cloudfront_with_ordered" {
  # source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.3.1" # use the latest release
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.5.0"

  # Configuration
  bucket_id          = module.s3_bucket.bucket_name
  bucket_domain_name = "${module.s3_bucket.bucket_name}.s3.eu-west-2.amazonaws.com"
  aliases            = [var.cloudfront_alias]
  aliases_cert_arn   = aws_acm_certificate_validation.cloudfront_alias_cert_validation.certificate_arn

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  service_area           = var.service_area

  enable_ordered_cache_behavior = true # default is false

  ordered_cache_behavior = {
    path_pattern = "/uploads/sites/64/*"
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
  }

  depends_on = [aws_acm_certificate_validation.cloudfront_alias_cert_validation]

}

resource "kubernetes_secret" "cloudfront_url" {
  metadata {
    name      = "cloudfront-output"
    namespace = var.namespace
  }

  data = {
    cloudfront_url   = module.cloudfront_with_ordered.cloudfront_url
    cloudfront_alias = var.cloudfront_alias
  }
}