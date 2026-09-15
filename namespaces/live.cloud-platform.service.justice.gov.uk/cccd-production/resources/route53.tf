resource "aws_route53_zone" "cccd_route53_zone" {
  name = var.domain

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

resource "kubernetes_secret" "cccd_route53_zone_sec" {
  metadata {
    name      = "cccd-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.cccd_route53_zone.zone_id
    name_servers = join("\n", aws_route53_zone.cccd_route53_zone.name_servers)
  }
}

resource "aws_route53_record" "cccd_route53_txt_asvdns" {
  zone_id = aws_route53_zone.cccd_route53_zone.zone_id
  name    = "_asvdns-92d02e3a-d85d-494a-bcf8-ae171fb84c1a.claim-crown-court-defence.service.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_d44746ad-298c-48f3-960f-04643dbfde09"]
}
