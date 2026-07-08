resource "aws_route53_zone" "cis-pp" {
  name = "cis-pp.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "cis-pp_route53_zone" {
  metadata {
    name      = "cis-pp-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.cis-pp.zone_id
    name_servers = join("\n", aws_route53_zone.cis-pp.name_servers)
  }
}

resource "aws_route53_record" "frontend" {
  count = var.use_custom_certificate ? 1 : 0

  zone_id = aws_route53_zone.cis-pp.zone_id
  name    = var.cloudfront_alias
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [aws_acm_certificate_validation.frontend]
}

resource "aws_route53_record" "cert_validations" {
  count = var.use_custom_certificate ? length(aws_acm_certificate.frontend[0].domain_validation_options) : 0

  zone_id = aws_route53_zone.cis-pp.zone_id
  name    = element(aws_acm_certificate.frontend[0].domain_validation_options[*].resource_record_name, count.index)
  type    = element(aws_acm_certificate.frontend[0].domain_validation_options[*].resource_record_type, count.index)
  records = [element(aws_acm_certificate.frontend[0].domain_validation_options[*].resource_record_value, count.index)]
  ttl     = 60

  allow_overwrite = true
}

