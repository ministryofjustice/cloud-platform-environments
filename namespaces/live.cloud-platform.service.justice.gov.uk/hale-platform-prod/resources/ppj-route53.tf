resource "aws_route53_zone" "ppj_route53_zone" {
  name = "prisonandprobationjobs.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "ppj_route53_zone_sec" {
  metadata {
    name      = "ppj-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  }
}

resource "aws_route53_record" "ppj_route53_a_record" {
  zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  name    = "prisonandprobationjobs.gov.uk"
  type    = "A"

  alias {
    name                   = "dualstack.ppj-p-loadb-1v5g2cm5si0du-1234011937.eu-west-2.elb.amazonaws.com."
    zone_id                = "Z10430412KWXTD8J6R39X"
    evaluate_target_health = false
  }

}

resource "aws_route53_record" "ppj_route53_mx_record" {
  zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  name    = "prisonandprobationjobs.gov.uk"
  type    = "MX"
  ttl     = "600"
  records = ["1 aspmx.l.google.com.","10 aspmx2.googlemail.com.","10 aspmx3.googlemail.com.","5 alt1.aspmx.l.google.com.","5 alt2.aspmx.l.google.com."]
}

resource "aws_route53_record" "ppj_route53_txt" {
  zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  name    = "prisonandprobationjobs.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=Cji2TFSPbuvDU9jGTd7bdcKIQQhaY6qaYSPbPauVW-0"]
}

resource "aws_route53_record" "ppj_route53_txt_dmarc" {
  zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  name    = "_dmarc.prisonandprobationjobs.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1;p=none;sp=none;rua=mailto:dmarc-rua@dmarc.service.gov.uk"]
}

resource "aws_route53_record" "ppj_route53_txt_smtp" {
  zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  name    = "_smtp._tls.prisonandprobationjobs.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "ppj_route53_txt_asvdns" {
  zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  name    = "_asvdns-731f3b3c-f499-4f2a-a07c-9088554d6137.prisonandprobationjobs.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_097f454c-583b-4fb1-b6d8-7919adcad592"]
}

resource "aws_route53_record" "ppj_route53_cname_record_googlehosted" {
  zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  name    = "4lokyq3e6h4r.prisonandprobationjobs.gov.uk"
  type    = "CNAME"
  ttl     = "600"
  records = ["gv-h77ed4yem7j6fp.dv.googlehosted.com."]
}

resource "aws_route53_record" "ppj_route53_cname_record_acm" {
  zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  name    = "_479ba9ec1862a427d6eb322f199f7b48.prisonandprobationjobs.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_a908c7c9414b858fb95d100bbbc536c9.acm-validations.aws"]
}

resource "aws_route53_record" "ppj_route53_cname_record_www" {
  zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  name    = "www.prisonandprobationjobs.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["prisonandprobationjobs.gov.uk"]
}

resource "aws_route53_record" "ppj_route53_cname_record_acm2" {
  zone_id = aws_route53_zone.ppj_route53_zone.zone_id
  name    = "_beead804eed69980ba265b0ec54a91f0.www.prisonandprobationjobs.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_6febb02e2ca1986bfb8a1c6a3f108ef0.acm-validations.aws"]
}

