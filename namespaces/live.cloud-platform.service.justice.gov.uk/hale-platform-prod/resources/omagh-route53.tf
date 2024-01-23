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
