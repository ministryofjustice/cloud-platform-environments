resource "aws_api_gateway_domain_name" "api_gateway_fqdn" {
  for_each = aws_acm_certificate_validation.api_gateway_custom_hostname

  domain_name              = aws_acm_certificate.api_gateway_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.api_gateway_custom_hostname[each.key].certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  mutual_tls_authentication {
    truststore_uri     = "s3://${module.s3_bucket.bucket_name}/${aws_s3_object.truststore.id}"
    truststore_version = aws_s3_object.truststore.version_id
  }

  depends_on = [
    aws_acm_certificate_validation.api_gateway_custom_hostname,
    aws_s3_object.truststore
  ]
}

resource "aws_acm_certificate" "api_gateway_custom_hostname" {
  domain_name       = "${var.hostname}.${var.base_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api_gateway_custom_hostname" {
  for_each = aws_route53_record.cert_validations

  certificate_arn         = aws_acm_certificate.api_gateway_custom_hostname.arn
  validation_record_fqdns = [aws_route53_record.cert_validations[each.key].fqdn]

  timeouts {
    create = "10m"
  }

  depends_on = [aws_route53_record.cert_validations]
}

data "aws_route53_zone" "iac_fees" {
  name         = var.base_domain
  private_zone = false
}

resource "aws_route53_record" "cert_validations" {
  for_each = {
    for dvo in aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.iac_fees.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_route53_record" "data" {
  for_each = aws_api_gateway_domain_name.api_gateway_fqdn

  zone_id = data.aws_route53_zone.iac_fees.zone_id
  name    = "${var.hostname}.${data.aws_route53_zone.iac_fees.name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api_gateway_fqdn[each.key].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_fqdn[each.key].regional_zone_id
    evaluate_target_health = false
  }
}
