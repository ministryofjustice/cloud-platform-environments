resource "aws_route53_zone" "route53_zone" {
  name = "checklegalaid.service.gov.uk"

  tags = {
    business-unit    = var.business_unit
    application      = var.application
    is-production    = var.is_production
    environment-name = var.environment-name
    owner            = var.team_name
    namespace        = var.namespace
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

resource "aws_route53_record" "checklegalaid_route53_txt_asvdns" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name = "_asvdns-31fc0209-db21-495d-8c86-9ef0e91341e4.checklegalaid.service.gov.uk"
  type = "TXT"
  ttl  = 300
  records = [
    "asvdns_d3ab4a6c-a469-4338-8164-1b646903014a"
  ]
}
