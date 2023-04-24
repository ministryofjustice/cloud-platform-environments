resource "aws_route53_zone" "imb_route53_zone" {
  name = "imb.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "imb_route53_zone_sec" {
  metadata {
    name      = "imb-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.imb_route53_zone.zone_id
  }
}
