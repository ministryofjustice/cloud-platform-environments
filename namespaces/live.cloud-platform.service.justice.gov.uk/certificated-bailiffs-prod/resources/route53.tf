resource "aws_route53_zone" "certbailiff_route53_zone" {
  name = "certificatedbailiffs.justice.gov.uk"

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

resource "kubernetes_secret" "certbailiff_route53_zone_sec" {
  metadata {
    name      = "certbailiff-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.certbailiff_route53_zone.zone_id
  }
}