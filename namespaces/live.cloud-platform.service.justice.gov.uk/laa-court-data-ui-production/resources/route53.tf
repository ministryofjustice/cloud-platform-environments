resource "aws_route53_zone" "lcdui_route53_zone" {
  name = var.domain

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "lcdui_route53_zone_sec" {
  metadata {
    name      = "lcdui-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.lcdui_route53_zone.zone_id
  }
}

