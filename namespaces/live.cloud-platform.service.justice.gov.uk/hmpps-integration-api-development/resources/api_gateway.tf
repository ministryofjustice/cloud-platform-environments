resource "aws_api_gateway_domain_name" "api_gateway_fqdn" {
  domain_name              = aws_acm_certificate.api_gateway_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.api_gateway_custom_hostname.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [aws_acm_certificate_validation.api_gateway_custom_hostname]
}

resource "aws_acm_certificate" "api_gateway_custom_hostname" {
  domain_name       = "${var.hostname}.${var.base_domain}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "api_gateway_custom_hostname" {
  certificate_arn         = aws_acm_certificate.api_gateway_custom_hostname.arn
  validation_record_fqdns = aws_route53_record.cert_validations.*.fqdn

  timeouts {
    create = "10m"
  }

  depends_on = [aws_route53_record.cert_validations]
}

data "aws_route53_zone" "hmpps" {
  name         = var.base_domain
  private_zone = false
}

resource "aws_route53_record" "cert_validations" {
  count = length(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options)

  zone_id = data.aws_route53_zone.hmpps.zone_id

  name    = element(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options.*.resource_record_name, count.index)
  type    = element(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options.*.resource_record_type, count.index)
  records = [element(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options.*.resource_record_value, count.index)]
  ttl     = 60
}

resource "aws_route53_record" "data" {
  zone_id = data.aws_route53_zone.hmpps.zone_id
  name    = "${var.hostname}.${data.aws_route53_zone.hmpps.name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api_gateway_fqdn.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_fqdn.regional_zone_id
    evaluate_target_health = false
  }
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name = var.namespace

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
