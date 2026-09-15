resource "aws_route53_zone" "sifocc_route53_zone" {
  name = "sifocc.org"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "sifocc_route53_zone_sec" {
  metadata {
    name      = "sifocc-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  }
}

resource "aws_route53_record" "sifocc_route53_mx_record_dxw" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "sifocc.org"
  type    = "MX"
  ttl     = "900"
  records = ["10 mail.dxw.net."]
}

resource "aws_route53_record" "sifocc_route53_txt_record_spf1" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "sifocc.org"
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 -all"]
}

resource "aws_route53_record" "sifocc_route53_cname_record_acm" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "_43383b25194dde9200c690f6b3e49e76.sifocc.org"
  type    = "CNAME"
  ttl     = "300"
  records = ["_8b2ab9946d72ca88f69640d7524c8f6a.acm-validations.aws."]
}

resource "aws_route53_record" "sifocc_route53_txt_record_asvdns" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "_asvdns-83a63262-df87-4cb1-aad8-bc508b6f5fb1.sifocc.org"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_46c60e1b-f01b-4ad9-b727-84f8cebe720e"]
}

resource "aws_route53_record" "sifocc_route53_txt_record_dmarc" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "_dmarc.sifocc.org"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1;p=reject;sp=reject;rua=mailto:dmarc-rua@dmarc.service.gov.uk"]
}

resource "aws_route53_record" "sifocc_route53_txt_record_domainkey" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "*._domainkey.sifocc.org"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; p="]
}

resource "aws_route53_record" "sifocc_route53_cname_record_sendgrid" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "s1._domainkey.sifocc.org"
  type    = "CNAME"
  ttl     = "300"
  records = ["s1.domainkey.u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "sifocc_route53_cname_record_sendgrid2" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "s2._domainkey.sifocc.org"
  type    = "CNAME"
  ttl     = "300"
  records = ["s2.domainkey.u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "sifocc_route53_cname_record_acm2" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "_e9d5906b7a58f5dc883d1ac38f916549.sifocc.org"
  type    = "CNAME"
  ttl     = "60"
  records = ["_2801696b77325b9a14a6232ed0fb2fff.nhqijqilxf.acm-validations.aws."]
}

resource "aws_route53_record" "sifocc_route53_txt_record_ncsc" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "_smtp._tls.sifocc.org"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "sifocc_route53_cname_record_em5025" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "em5025.sifocc.org"
  type    = "CNAME"
  ttl     = "300"
  records = ["u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "sifocc_route53_cname_record_acm3" {
  zone_id = aws_route53_zone.sifocc_route53_zone.zone_id
  name    = "_e2d21717539b5d4b2a754b28fde96448.www.sifocc.org"
  type    = "CNAME"
  ttl     = "60"
  records = ["_5b92fe501dc16c654ef4577bed89ee51.nhqijqilxf.acm-validations.aws."]
}
