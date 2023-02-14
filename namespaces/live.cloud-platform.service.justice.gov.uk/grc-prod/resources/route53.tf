resource "aws_route53_zone" "route53_zone" {
  name = "gender-recognition.service.justice.gov.uk"

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

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_zone.zone_id
  }
}

resource "aws_route53_zone" "route53_zone_apply" {
  name = "apply-gender-recognition-certificate.service.gov.uk"

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

resource "kubernetes_secret" "route53_zone_sec_apply" {
  metadata {
    name      = "route53-zone-apply-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_zone_apply.zone_id
  }
}
