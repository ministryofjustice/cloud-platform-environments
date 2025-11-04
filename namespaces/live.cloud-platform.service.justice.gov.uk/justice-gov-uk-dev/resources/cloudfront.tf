module "cloudfront" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.3.0"

  # Configuration
  bucket_id          = module.s3_bucket.bucket_name
  bucket_domain_name = "${module.s3_bucket.bucket_name}.s3.eu-west-2.amazonaws.com"
  # The cloudfront module accepts a list of aliases, but we only need one.
  aliases              = [var.cloudfront_alias]
  # SSL certificate for the CloudFront alias.
  aliases_cert_arn     = aws_acm_certificate.cloudfront_alias_cert.arn

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  depends_on = [aws_acm_certificate.cloudfront_alias_cert]
}

data "kubernetes_secret" "cloudfront_input_secret" {
  metadata {
    name      = "cloudfront-input"
    namespace = var.namespace
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
  }
}
