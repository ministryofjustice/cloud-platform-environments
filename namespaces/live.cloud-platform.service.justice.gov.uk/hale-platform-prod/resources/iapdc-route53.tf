resource "aws_route53_zone" "iapdc_route53_zone" {
  name = "iapondeathsincustody.org"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "iapdc_route53_zone_sec" {
  metadata {
    name      = "iapdc-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.iapdc_route53_zone.zone_id
  }
}

resource "aws_route53_record" "iapdc_route53_txt" {
  zone_id = aws_route53_zone.iapdc_route53_zone.zone_id
  name    = "iapondeathsincustody.org"
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 ~all", "google-site-verification=frPkiUR1vX9lUNpEoHg6dOpOgZAlKoe-DrlrNOy02oI"]
}