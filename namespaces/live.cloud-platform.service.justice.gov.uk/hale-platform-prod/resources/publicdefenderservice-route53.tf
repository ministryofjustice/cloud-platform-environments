resource "aws_route53_zone" "publicdefenderservice_route53_zone" {
  name = "publicdefenderservice.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "publicdefenderservice_route53_zone_sec" {
  metadata {
    name      = "publicdefenderservice-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.publicdefenderservice_route53_zone.zone_id
  }
}

resource "aws_route53_record" "publicdefenderservice_route53_a_record" {
  zone_id = aws_route53_zone.publicdefenderservice_route53_zone.zone_id
  name    = "publicdefenderservice.org.uk"
  type    = "A"
  ttl     = "300"

  alias {
    name                   = "dualstack.jotwp-loadb-1mbwraz503eq6-1769122100.eu-west-2.elb.amazonaws.com."
    zone_id                = "ZHURV8PSTC4K8"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "publicdefenderservice_route53_verification_record" {
  zone_id = aws_route53_zone.publicdefenderservice_route53_zone.zone_id
  name    = "publicdefenderservice.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=UjveRRCX7znc8Txa1iunmJ4fi3fqbTlq1PToBYiOoeQ"]
}

resource "aws_route53_record" "publicdefenderservice_route53_cname_record_verification_acm" {
  zone_id = aws_route53_zone.publicdefenderservice_route53_zone.zone_id
  name    = "_ecd4d7fd06f7a8747dea80d6916c72ff.publicdefenderservice.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_b00c4b6fa166512ac8dcb0e527c6402c.tfmgdnztqk.acm-validations.aws."]
}

resource "aws_route53_record" "publicdefenderservice_route53_cname_record_verification_www" {
  zone_id = aws_route53_zone.publicdefenderservice_route53_zone.zone_id
  name    = "www.publicdefenderservice.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["publicdefenderservice.org.uk."]
}

resource "aws_route53_record" "publicdefenderservice_route53_cname_record_verification_acm_www" {
  zone_id = aws_route53_zone.publicdefenderservice_route53_zone.zone_id
  name    = "_f330287d1fa7ebbaecb8bba3b4c535b8.www.publicdefenderservice.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_883f57125ff59399c0009690a7d3779d.tfmgdnztqk.acm-validations.aws."]
}
