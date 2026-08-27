# An aws_acm_certificate for the CloudFront alias.

resource "aws_acm_certificate" "cloudfront_alias_cert" {
  domain_name       = var.cloudfront_alias
  validation_method = "DNS"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
    team_name              = var.team_name
  }

  # For CloudFront, the ACM certificate must be in the us-east-1 region.
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html#https-requirements-certificate-issuer
  provider = aws.virginia

  lifecycle {
    create_before_destroy = true
  }
}
