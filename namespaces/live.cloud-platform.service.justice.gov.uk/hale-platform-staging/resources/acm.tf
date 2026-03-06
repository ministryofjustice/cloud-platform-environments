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

# aws_acm_certificate_validation for the CloudFront alias.
# This is part of the validation workflow and not a a real-world entity in AWS.
# The resource is used together with aws_route53_record and aws_acm_certificate
# to request a DNS validated certificate, deploy the required validation records 
# and wait for validation to complete.

resource "aws_acm_certificate_validation" "cloudfront_alias_cert_validation" {
  certificate_arn         = aws_acm_certificate.cloudfront_alias_cert.arn
  validation_record_fqdns = aws_route53_record.cert_validations[*].fqdn 

  provider = aws.virginia

  timeouts {
    create = "10m"
  }

  depends_on = [
    aws_acm_certificate.cloudfront_alias_cert,
    aws_route53_record.cert_validations
  ]
}