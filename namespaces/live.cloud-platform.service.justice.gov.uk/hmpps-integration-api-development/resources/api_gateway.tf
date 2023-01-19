resource "aws_api_gateway_domain_name" "api_gateway_fqdn" {
  domain_name              = aws_acm_certificate.api_gateway_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.api_gateway_custom_hostname.certificate_arn
  security_policy = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [aws_acm_certificate_validation.api_gateway_custom_hostname]
}

resource "aws_acm_certificate" "api_gateway_custom_hostname" {
  domain_name       = "${var.hostname}.${var.base_domain}"
  validation_method = "DNS"

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

resource "aws_acm_certificate_validation" "api_gateway_custom_hostname" {
  certificate_arn         = aws_acm_certificate.api_gateway_custom_hostname.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validations : record.fqdn]

  timeouts {
    create = "10m"
  }

  depends_on = [aws_route53_record.cert_validations]
}

resource "aws_route53_record" "cert_validations" {
  for_each = {
    for dvo in aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 3600
  type    = each.value.type
  zone_id = data.kubernetes_secret.zone_id.data["zone_id"]
}


data "kubernetes_secret" "zone_id" {
  metadata {
    name      = "route53-justice-zone-output"
    namespace = var.production_namespace
  }
}

resource "aws_route53_record" "data" {
  name    = aws_api_gateway_domain_name.api_gateway_fqdn.domain_name
  type    = "A"
  zone_id = data.kubernetes_secret.zone_id.data["zone_id"]

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api_gateway_fqdn.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_fqdn.regional_zone_id
  }
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name = var.namespace

  endpoint_configuration {
    types = ["REGIONAL"]
  }

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
