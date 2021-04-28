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

# Service hosted in Azure (is being migrated to CP)
resource "aws_route53_record" "hwpv-azure" {
  zone_id = aws_route53_zone.route53_zone_hwpv.zone_id
  name    = "help-with-prison-visits.service.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["51.140.33.178"]
}

resource "aws_route53_record" "caseworker-cname" {
  zone_id = aws_route53_zone.route53_zone_hwpv.zone_id
  name    = "caseworker.help-with-prison-visits.service.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["e0e8c2cb-80cc-4087-a192-3b8fb4b49b2a.cloudapp.net"]
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
