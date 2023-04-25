resource "aws_route53_zone" "imb_route53_zone" {
  name = "imb.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "imb_route53_zone_sec" {
  metadata {
    name      = "imb-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.imb_route53_zone.zone_id
  }
}

resource "aws_route53_record" "imb_route53_a_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "imb.org.uk"
  type    = "A"

  alias {
    name                   = "jotwp-loadb-1mbwraz503eq6-1769122100.eu-west-2.elb.amazonaws.com."
    zone_id                = "ZHURV8PSTC4K8"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "imb_sts_a_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "mta-sts.imb.org.uk"
  type    = "A"

  alias {
    name                   = "d3s1p7nop9zosl.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "imb_route53_mx_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "imb.org.uk"
  type    = "MX"
  ttl     = "300"
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}

resource "aws_route53_record" "imb_spf1_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 -all"]
}

resource "aws_route53_record" "imb_aws_ses_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_amazonses.imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["DfZptPG81IShblj0yJ1jmGiqOOPyFuJQdNluGjeUi+w="]
}

resource "aws_route53_record" "imb_dmarc_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_dmarc.imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1;p=none;sp=none;rua=mailto:dmarc-rua@dmarc.service.gov.uk"]
}

resource "aws_route53_record" "imb_mta_sts_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_mta-sts.imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=STSv1; id=1fb6a833a76222e0887ff81096b27ccd"]
}

resource "aws_route53_record" "imb_smtp_tls_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_smtp._tls.imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "imb_cname_acm_validation_02_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_a17f291094c56738f53f60414269a15f.imb.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_8434a359b8481c5767ade4985b20f14c.hkvuiqjoua.acm-validations.aws."]
}

resource "aws_route53_record" "imb_cname_mts_sts_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_bec7b6a29ca37a0129b2033111e16a61.mta-sts.imb.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_9d4ff3184451a4b050bbfa16a32b366d.bkngfjypgb.acm-validations.aws."]
}

resource "aws_route53_record" "imb_cname_myimb_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "my.imb.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["imbmembers.prod.wp.dsd.io"]
}

resource "aws_route53_record" "imb_cname_myimb_acm_validation_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_3fc8a2dfb41e5703485146ebfdc6fe3d.my.imb.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_25ce653534cfe69d486bf5196e4c76d8.hkvuiqjoua.acm-validations.aws."]
}

resource "aws_route53_record" "imb_cname_www_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "www.imb.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["imb.org.uk"]
}

resource "aws_route53_record" "imb_cname_www_acm_validation_aws_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_bfd2574796bb803800192be042cb12fa.www.imb.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_f39b2d1c51943d6f617b24ded0373daa.hkvuiqjoua.acm-validations.aws."]
}
