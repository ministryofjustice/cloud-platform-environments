resource "aws_route53_zone" "ccrc_route53_zone" {
  name = "ccrc.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "ccrc_route53_zone_sec" {
  metadata {
    name      = "ccrc-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  }
}

resource "aws_route53_record" "ccrc_route53_a_record" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "ccrc.gov.uk"
  type    = "A"

  alias {
    name                   = "dualstack.jotwp-loadb-1mbwraz503eq6-1769122100.eu-west-2.elb.amazonaws.com."
    zone_id                = "ZHURV8PSTC4K8"
    evaluate_target_health = false
  }

}

resource "aws_route53_record" "ccrc_route53_a_record_connect" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "connect.ccrc.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["178.239.100.157"]
}

resource "aws_route53_record" "ccrc_route53_a_record_ftp" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "ftp.ccrc.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["79.170.44.17"]
}

resource "aws_route53_record" "ccrc_route53_a_record_mail" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mail.ccrc.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["79.170.44.57"]
}

resource "aws_route53_record" "ccrc_route53_a_record_mail2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mail2.ccrc.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["20.49.250.153"]
}

resource "aws_route53_record" "ccrc_route53_a_record_mta" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mta-sts.ccrc.gov.uk"
  type    = "A"

  alias {
    name                   = "d17g7hcsgudvb4.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ccrc_route53_mx_record_outlook" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "ccrc.gov.uk"
  type    = "MX"
  ttl     = "300"
  records = ["10 CCRC-gov-uk.mail.protection.outlook.com."]
}

resource "aws_route53_record" "ccrc_route53_txt_record_main" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["MS=ms13510705", "moTzn29k+pERDZNgHyOtkGiR+/ckQKBhpJDwsM558yZCe4wETnTgQswUIVDMjxIQrRQyPxznbg0qy6o17si9qQ==", "v=spf1 include:spf.protection.outlook.com ip4:80.6.91.150 -all"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_asvdns" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_asvdns-332ae0bd-1b7a-46fd-825b-cfcbda0c2f0c.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["asvdns_feca725b-fbca-49e0-8928-f647ef79edb0"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_dmarc" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_dmarc.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DMARC1;p=quarantine;rua=mailto:PSm6GLjJ2Yt@dmarc-rua.mailcheck.service.ncsc.gov.uk;"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_mta_sts" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_mta-sts.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=STSv1; id=61658d49bbc2aee51b11cebf1d37ae83"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_smtp" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_smtp._tls.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_smtp2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_smtp._tls.imb.org.uk.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_acm" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_5770ab00d5e1032ff7db591706b2f9a5.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_bd266e83797378e89bcbbc42c6974047.jhztdrwbnw.acm-validations.aws."]
}

resource "aws_route53_record" "ccrc_route53_cname_record_mwn" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mwn._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwn.domainkey.u25846363.wl114.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_mwn2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mwn2._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwn2.domainkey.u25846363.wl114.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_mwo" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mwo._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwo.domainkey.u26084809.wl060.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_mwo2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mwo2._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwo2.domainkey.u26084809.wl060.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_selector1" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "selector1._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["selector1-ccrc-gov-uk._domainkey.ccrcuk.onmicrosoft.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_selector2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "selector2._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["selector2-ccrc-gov-uk._domainkey.ccrcuk.onmicrosoft.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "autodiscover.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["autodiscover.outlook.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_sendgrid" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "em6039.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u25846363.wl114.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_sendgrid2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "em6531.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u26084809.wl060.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_enterpriseenrollment" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "enterpriseenrollment.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseenrollment.manage.microsoft.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_enterpriseregistration" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "enterpriseregistration.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseregistration.windows.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_lyncdiscover" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "lyncdiscover.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["webdir.online.lync.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_mta_sts2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_9e111899dbb1e73aed800dd796c849f4.mta-sts.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_529da6734664ecca58ad43f6298844fe.bkngfjypgb.acm-validations.aws."]
}

resource "aws_route53_record" "ccrc_route53_cname_record_sipdir" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "sip.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["sipdir.online.lync.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_www" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "www.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["ccrc.gov.uk"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_acm2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_2966249ff1f7d496b355eabc821707b3.www.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_054556e3de8c167ce984f414fdf89e12.jhztdrwbnw.acm-validations.aws."]
}

resource "aws_route53_record" "ccrc_route53_srv_record_sipfed" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_sipfederationtls._tcp.ccrc.gov.uk"
  type    = "SRV"
  ttl     = "3600"
  records = ["5061 1 100 sipfed.online.lync.com"]
}

resource "aws_route53_record" "ccrc_route53_srv_record_sipdir" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_sip._tls.ccrc.gov.uk"
  type    = "SRV"
  ttl     = "3600"
  records = ["443 1 100 sipdir.online.lync.com"]
}