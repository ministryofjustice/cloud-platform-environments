resource "aws_route53_zone" "justicedata_route53_zone" {
  name = var.domain

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.owner
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "justicedata_route53_zone_sec" {
  metadata {
    name      = "justicedata-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.justicedata_route53_zone.zone_id
  }
}

resource "aws_route53_record" "justicedata_route53_zone_cname0_record" {
  name    = "_0202d4e448b9dc698a779ca6faa760a8.${var.domain}"
  zone_id = aws_route53_zone.justicedata_route53_zone.zone_id
  type    = "CNAME"
  records = ["F5C15BF318A1459FA7FD064E46A8C336.4651BB299FC506838CC583D3533979EF.22ab6168adc1c019f687.comodoca.com."]
  ttl     = "300"
}

resource "aws_route53_record" "justicedata_route53_zone_cname1_record" {
  name    = "_6e66bde5693afcf24e3c6f6f1eb5d62a.${var.domain}"
  zone_id = aws_route53_zone.justicedata_route53_zone.zone_id
  type    = "CNAME"
  records = ["27D48CD4FAA246277AD492FE0854993E.949CF41E1AFB5F686396AA072AB12A09.21c34fc0440021bd4f98.comodoca.com."]
  ttl     = "300"
}

