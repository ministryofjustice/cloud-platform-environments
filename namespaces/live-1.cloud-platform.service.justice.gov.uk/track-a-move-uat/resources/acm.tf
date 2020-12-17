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
  certificate_arn = aws_acm_certificate.apigw_custom_hostname.arn
}
