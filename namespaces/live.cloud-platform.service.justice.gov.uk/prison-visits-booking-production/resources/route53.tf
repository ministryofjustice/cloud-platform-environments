resource "aws_route53_zone" "route53_zone" {
  name = "prisonvisits.service.gov.uk"

  tags = {
    business-unit          = "HMPPS"
    application            = "PVB"
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
    zone_id = aws_route53_zone.route53_zone.zone_id
  }
}

resource "aws_route53_zone" "route53_justice_zone" {
  name = "prisonvisits.service.justice.gov.uk"

  tags = {
    business-unit          = "HMPPS"
    application            = "PVB"
    is-production          = var.is_production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_justice_zone_sec" {
  metadata {
    name      = "route53-justice-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_justice_zone.zone_id
  }
}

resource "aws_route53_record" "pvb_route53_txt_asvdns" {
  zone_id = aws_route53_zone.pvb_route53_zone.zone_id
  name    = "_asvdns-5d217551-d334-459c-a153-a1e8c343ec32.prisonvisits.service.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_8b3ffd09-9217-46cc-be7d-35a8f258b7ff"]
}
