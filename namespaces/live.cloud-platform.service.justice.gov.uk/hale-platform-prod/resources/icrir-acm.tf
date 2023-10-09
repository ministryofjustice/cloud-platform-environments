resource "aws_acm_certificate" "icrir_custom_certificate" {
  domain_name       = "icrir.independent-inquiry.uk"
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "kubernetes_secret" "icrir_acm_validation_cname" {

  metadata {
    name      = "icrir-acm-validation-cname-output"
    namespace = var.namespace
  }
  data = {
    "name" = element(aws_acm_certificate.icrir_custom_certificate.domain_validation_options[*].resource_record_name,0)
    "type"    = element(aws_acm_certificate.icrir_custom_certificate.domain_validation_options[*].resource_record_type,0)
    "records" = element(aws_acm_certificate.icrir_custom_certificate.domain_validation_options[*].resource_record_value,0)
  }
}