resource "aws_route53_zone" "cloudfront_route53_zone" {
  name = var.cloudfront_alias

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert-validations" {
  count           = length(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options)

  zone_id         = aws_route53_zone.cloudfront_route53_zone.zone_id

  name            = element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_name, count.index)
  type            = element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_type, count.index)
  records         = [element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_value, count.index)]
  ttl             = 60
  allow_overwrite = true

  depends_on      = [aws_acm_certificate.cloudfront_alias_cert]
}

resource "aws_acm_certificate_validation" "cloudfront_alias_cert_validation" {
  certificate_arn         = aws_acm_certificate.cloudfront_alias_cert.arn
  validation_record_fqdns = aws_route53_record.cert-validations[*].fqdn 

  timeouts {
    create = "10m"
  }

  depends_on = [aws_route53_record.cert-validations]
}

resource "aws_route53_record" "cloudfront_aws_route53_record" {
  name    = var.cloudfront_alias
  zone_id = aws_route53_zone.cloudfront_route53_zone.zone_id
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_url
    zone_id                = module.cloudfront.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

