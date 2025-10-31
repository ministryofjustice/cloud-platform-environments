module "cloudfront" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.3.1" # use the latest release

  # Configuration
  bucket_id          = module.s3_bucket.bucket_name
  bucket_domain_name = "${module.s3_bucket.bucket_name}.s3.eu-west-2.amazonaws.com"
  aliases           = [var.cloudfront_alias]
  aliases_cert_arn     = aws_acm_certificate_validation.cloudfront_alias_cert_validation.certificate_arn

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # apply the 7-day edge cache policy
  default_cache_behavior = {
    cache_policy_id = aws_cloudfront_cache_policy.seven_days_strict.id
  }

  depends_on = [aws_acm_certificate_validation.cloudfront_alias_cert_validation]

}

resource "kubernetes_secret" "cloudfront_url" {
  metadata {
    name      = "cloudfront-output"
    namespace = var.namespace
  }

  data = {
    cloudfront_url   = module.cloudfront.cloudfront_url
    cloudfront_alias = var.cloudfront_alias
  }
}

resource "aws_cloudfront_cache_policy" "seven_days_strict" {
  name        = "seven-days-fixed"
  min_ttl     = 604800  # 7d
  default_ttl = 604800  # 7d
  max_ttl     = 604800  # 7d

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config  { cookie_behavior = "none" }
    headers_config  { header_behavior = "none" }
    query_strings_config { query_string_behavior = "none" }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}