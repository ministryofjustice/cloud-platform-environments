resource "aws_route53_zone" "cla_frontend_route53_zone" {
  name = "cases.civillegaladvice.service.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "cla_frontend_route53_zone_sec" {
  metadata {
    name      = "cla-frontend-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.cla_frontend_route53_zone.zone_id
  }
}

resource "aws_route53_record" "cla_frontend_route53_txt_record_asvdns" {
  zone_id = aws_route53_zone.cla_frontend_route53_zone.zone_id
  name    = "_asvdns-3604cc83-4a12-4587-b390-73935bc9ba8d.cases.civillegaladvice.service.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_26ffb1eb-87ad-4ba7-9353-26ea5fc2f5fd"]
}
