resource "aws_acm_certificate" "apigw_custom_hostname" {
  domain_name       = "${var.hostname}.${var.base_domain}"
  validation_method = "DNS"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_acm_certificate_validation" "apigw_custom_hostname" {
  certificate_arn         = aws_acm_certificate.apigw_custom_hostname.arn
  validation_record_fqdns = aws_route53_record.cert-validations.*.fqdn

  timeouts {
    create = "5m"
  }
}

resource "aws_route53_record" "cert-validations" {
  count = length(aws_acm_certificate.apigw_custom_hostname.domain_validation_options)

  zone_id = data.kubernetes_secret.zone_id.data["zone_id"]

  name    = element(aws_acm_certificate.apigw_custom_hostname.domain_validation_options.*.resource_record_name, count.index)
  type    = element(aws_acm_certificate.apigw_custom_hostname.domain_validation_options.*.resource_record_type, count.index)
  records = [element(aws_acm_certificate.apigw_custom_hostname.domain_validation_options.*.resource_record_value, count.index)]
  ttl     = 60
}


data "kubernetes_secret" "zone_id" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.base_domain_route53_namespace
  }
}

resource "aws_route53_record" "data" {
  name    = aws_api_gateway_domain_name.apigw_fqdn.domain_name
  type    = "A"
  zone_id = data.kubernetes_secret.zone_id.data["zone_id"]

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.apigw_fqdn.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.apigw_fqdn.regional_zone_id
  }
}
