resource "aws_route53_zone" "route53_zone_hwpv" {
  name = "help-with-prison-visits.service.gov.uk"

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}

resource "kubernetes_secret" "route53_zone" {
  metadata {
    name      = "route53-dns-zone-nameservers"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    zone_id      = aws_route53_zone.route53_zone_hwpv.zone_id
    name_servers = join(", ", aws_route53_zone.route53_zone_hwpv.name_servers)
  }
}
