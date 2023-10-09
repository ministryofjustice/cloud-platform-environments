resource "aws_route53_zone" "icrir_route53_zone" {
  name = "icrir.independent-inquiry.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "icrir_route53_zone_sec" {
  metadata {
    name      = "icrir-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  }
}

resource "aws_route53_record" "icrir_route53_cname_www_record" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "www.icrir.independent-inquiry.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["icrir.independent-inquiry.uk"]
}
