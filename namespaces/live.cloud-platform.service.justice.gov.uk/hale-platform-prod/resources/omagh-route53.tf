resource "aws_route53_zone" "omagh_route53_zone" {
  name = "omagh.independent-inquiry.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "omagh_route53_zone_sec" {
  metadata {
    name      = "omagh-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  }
}

resource "aws_route53_record" "omagh_route53_txt_asvdns" {
  zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  name    = "_asvdns-9bd05310-34f8-4f9e-abf7-9b2dd481be48.omagh.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["asvdns_96a49327-cddb-476d-8cbf-6d218630e474"]
}

resource "aws_route53_record" "omagh_route53_mx_records" {
  zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  name    = "omagh.independent-inquiry.uk"
  type    = "MX"
  ttl     = "3600"
  records = [
    "10 mail1.nics.gov.uk",
    "10 mail2.nics.gov.uk",
    "10 mail3.nics.gov.uk",
    "10 mail4.nics.gov.uk",
    "10 mail5.nics.gov.uk",
    "10 mail6.nics.gov.uk",
    "10 mail7.nics.gov.uk",
    "10 mail8.nics.gov.uk"
  ]
}
