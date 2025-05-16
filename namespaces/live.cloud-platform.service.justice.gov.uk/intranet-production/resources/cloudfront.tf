module "cloudfront" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.3.1"

  # Configuration
  bucket_id            = module.s3_bucket.bucket_name
  bucket_domain_name   = "${module.s3_bucket.bucket_name}.s3.eu-west-2.amazonaws.com"
  # The cloudfront module accepts a list of aliases, but we only need one.
  aliases              = [var.cloudfront_alias]
  # SSL certificate for the CloudFront alias.
  aliases_cert_arn     = aws_acm_certificate.cloudfront_alias_cert.arn
  # An array of public keys with comments, to be used for CloudFront. Includes an optional entry for an expiring key
  # !IMPORTANT! This value should NEVER be exactly equal to null. If it is, the CloudFront distribution & S3 bucket will be public.
  trusted_public_keys  = local.expiring_trusted_key.encoded_key == null ? [local.trusted_key] : [local.trusted_key, local.expiring_trusted_key]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # Custom error pages for every error code
  # 400, 401, 403, 404, 405, 412, 500, 502, 503, 504
  custom_error_response = [
    {
      error_code            = 400
      response_code         = 400
      response_page_path    = "/error_pages/400.html"
    },
    {
      error_code            = 401
      response_code         = 401
      response_page_path    = "/error_pages/401.html"
      error_caching_min_ttl = 0
    },
    {
      error_code            = 403
      response_code         = 403
      response_page_path    = "/error_pages/403.html"
      error_caching_min_ttl = 0
    },
    {
      error_code            = 404
      response_code         = 404
      response_page_path    = "/error_pages/404.html"
    },
    {
      error_code            = 405
      response_code         = 405
      response_page_path    = "/error_pages/405.html"
    },
    {
      error_code            = 412
      response_code         = 412
      response_page_path    = "/error_pages/412.html"
    },
    {
      error_code            = 500
      response_code         = 500
      response_page_path    = "/error_pages/500.html"
    },
    {
      error_code            = 502
      response_code         = 502
      response_page_path    = "/error_pages/502.html"
    },
    {
      error_code            = 503
      response_code         = 503
      response_page_path    = "/error_pages/503.html"
    },
    {
      error_code            = 504
      response_code         = 504
      response_page_path    = "/error_pages/504.html"
    }
  ]

  depends_on = [aws_acm_certificate.cloudfront_alias_cert]
}

data "kubernetes_secret" "cloudfront_input_secret" {
  metadata {
    name      = "cloudfront-input"
    namespace = var.namespace
  }
}

locals {
  trusted_key          = {
    encoded_key = data.kubernetes_secret.cloudfront_input_secret.data.AWS_CLOUDFRONT_PUBLIC_KEY
    comment     = ""
    associate   = true
  }
  expiring_trusted_key = {
    encoded_key = try(data.kubernetes_secret.cloudfront_input_secret.data.AWS_CLOUDFRONT_PUBLIC_KEY_EXPIRING, null)
    comment     = ""
    associate   = true
  }
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
