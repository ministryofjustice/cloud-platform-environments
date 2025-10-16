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

resource "aws_route53_record" "imb_route53_a_record_sts" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "mta-sts.imb.org.uk"
  type    = "A"

  alias {
    name                   = "d3s1p7nop9zosl.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "imb_route53_mx_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "imb.org.uk"
  type    = "MX"
  ttl     = "300"
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}

resource "aws_route53_record" "imb_route53_txt_records" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=spf1 include:amazonses.com include:spf.brevo.com -all",
    "brevo-code:5df81568a8579db8c5271574de58f6bb"
  ]
}

resource "aws_route53_record" "imb_route53_txt_aws_ses_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_amazonses.imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["DfZptPG81IShblj0yJ1jmGiqOOPyFuJQdNluGjeUi+w="]
}

resource "aws_route53_record" "imb_route53_txt_dmarc_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_dmarc.imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1;p=none;sp=none;rua=mailto:dmarc-rua@dmarc.service.gov.uk,mailto:rua@dmarc.brevo.com"]
}

resource "aws_route53_record" "imb_route53_txt_asvdns_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_asvdns-dc13114f-40e1-4aea-870b-b494c231eafe.imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_23c13fcf-e91a-4f95-aed0-927fe046ad79"]
}

resource "aws_route53_record" "imb_route53_txt_mta_sts_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_mta-sts.imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=STSv1; id=1fb6a833a76222e0887ff81096b27ccd"]
}

resource "aws_route53_record" "imb_route53_txt_smtp_tls_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_smtp._tls.imb.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "imb_route53_cname_acm_validation_02_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_a17f291094c56738f53f60414269a15f.imb.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_8434a359b8481c5767ade4985b20f14c.hkvuiqjoua.acm-validations.aws."]
}

resource "aws_route53_record" "imb_route53_cname_mts_sts_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_bec7b6a29ca37a0129b2033111e16a61.mta-sts.imb.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_9d4ff3184451a4b050bbfa16a32b366d.bkngfjypgb.acm-validations.aws."]
}

resource "aws_route53_record" "imb_route53_cname_myimb_acm_validation_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_3fc8a2dfb41e5703485146ebfdc6fe3d.my.imb.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_25ce653534cfe69d486bf5196e4c76d8.hkvuiqjoua.acm-validations.aws."]
}

resource "aws_route53_record" "imb_route53_cname_www_acm_validation_aws_record" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_bfd2574796bb803800192be042cb12fa.www.imb.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_f39b2d1c51943d6f617b24ded0373daa.hkvuiqjoua.acm-validations.aws."]
}

resource "aws_route53_record" "imb_route53_dkim1" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "brevo1._domainkey.imb.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["b1.imb-org-uk.dkim.brevo.com"]
}

resource "aws_route53_record" "imb_route53_dkim2" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "brevo2._domainkey.imb.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["b2.imb-org-uk.dkim.brevo.com"]
}

resource "aws_route53_record" "imb_route53_dcv_uat_applications" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_7yww96sqdop2re50llypxhy8wytpi76.uat.applications.imb.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["dcv.digicert.com."]
}

resource "aws_route53_record" "imb_route53_dcv_www_uat_applications" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_7yww96sqdop2re50llypxhy8wytpi76.www.uat.applications.imb.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["dcv.digicert.com."]
}

resource "aws_route53_record" "imb_route53_dcv_applications" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_s2gwsz71c9juh61c1n6ps7jaj0lqidh.applications.imb.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["dcv.digicert.com."]
}

resource "aws_route53_record" "imb_route53_dcv_www_applications" {
  zone_id = aws_route53_zone.imb_route53_zone.zone_id
  name    = "_s2gwsz71c9juh61c1n6ps7jaj0lqidh.www.applications.imb.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["dcv.digicert.com."]
}
