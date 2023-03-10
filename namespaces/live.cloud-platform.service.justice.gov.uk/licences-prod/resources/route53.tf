resource "aws_route53_zone" "route53_zone" {
  name = "licences.service.hmpps.dsd.io"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment-name
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
    zone_id      = aws_route53_zone.route53_zone.zone_id
    name_servers = join(", ", aws_route53_zone.route53_zone.name_servers)
  }
}

