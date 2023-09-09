resource "aws_route53_zone" "ppo_route53_zone" {
  name = "ppo.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "ppo_route53_zone_sec" {
  metadata {
    name      = "ppo-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  }
}

resource "aws_route53_record" "ppo_route53_a_record" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "ppo.gov.uk"
  type    = "A"
  ttl     = "300"

  alias {
    name                   = "dualstack.ppo-p-loadb-1dvbse409la2x-1010225236.eu-west-2.elb.amazonaws.com."
    zone_id                = ""
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ppo_route53_mx_record_outlook" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "ppo.gov.uk"
  type    = "MX"
  ttl     = "300"
  records = ["0 ppo-gov-uk.mail.protection.outlook.com"]
}

resource "aws_route53_record" "ppo_route53_txt_record_ms" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["MS=ms15192188"]
}

resource "aws_route53_record" "ppo_route53_txt_record_spf1" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 ip4:194.33.196.8/32 ip4:194.33.192.8/32 include:spf.protection.outlook.com include:servers.mcsv.net -all"]
}

resource "aws_route53_record" "ppo_route53_txt_record_atlassian" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["atlassian-domain-verification=eZYa71sfUYC3GKWDAnR6IDBAD7m0PkEaKKOYkM2cjWj8or0XT0PwqvFpqTLtaNby"]
}

resource "aws_route53_record" "ppo_route53_cname_record_acm" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_253863dcd7c6082e4f0d800941a4e4bb.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_d04ba8ce18e13c0cdea659d1362a86dd.jhztdrwbnw.acm-validations.aws."]
}

resource "aws_route53_record" "ppo_route53_cname_record_dmarc" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_dmarc.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_dmarc_ttp_policy.justice.gov.uk"]
}

resource "aws_route53_record" "ppo_route53_txt_record_dkim1" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "fp01._domainkey.ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCN/Dnp6gO1PJVQgLljNpkkvVUH/G04C2QkC28j8ddX13V7MAvDWpCxnUfTPy8C27njUImSa8b2TwyeA0P2ONPHQhW652tSxZa0+VT2b5qRFhne3UigZEeKhix988mhlOTO+6PN4+JR7MPXSeE0iGGPWm8m4JsxeaVvwN0XC92yvQIDAQAB;"]
}

resource "aws_route53_record" "ppo_route53_cname_record_k1" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "k1._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["dkim.mcsv.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_sendgrid1" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "s1._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["s1.domainkey.u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_sendgrid2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "s2._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["s2.domainkey.u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_onmicrosoft" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "selector1._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["selector1-ppo-gov-uk._domainkey.JusticeUK.onmicrosoft.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_onmicrosoft2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "selector2._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["selector2-ppo-gov-uk._domainkey.JusticeUK.onmicrosoft.com"]
}

resource "aws_route53_record" "ppo_route53_txt_record_github" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_github-challenge-moj-analytical-services.ppo.gov.uk"
  type    = "TXT"
  ttl     = "60"
  records = ["fba0295f0f"]
}

resource "aws_route53_record" "ppo_route53_txt_record_mta" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_mta-sts.ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=STSv1; id=e3591c0ba3581f07d0c7f4826a9b5b34"]
}

resource "aws_route53_record" "ppo_route53_srv_record_sipfed" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_sipfederationtls._tcp.ppo.gov.uk"
  type    = "SRV"
  ttl     = "300"
  records = ["100 1 5061 sipfed.online.lync.com"]
}

resource "aws_route53_record" "ppo_route53_srv_record_sipfed2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_sip._tls.ppo.gov.uk"
  type    = "SRV"
  ttl     = "300"
  records = ["100 1 443 sipdir.online.lync.com"]
}

resource "aws_route53_record" "ppo_route53_txt_record_ncsc" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_smtp._tls.ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "ppo_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "autodiscover.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["sautodiscover.outlook.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_sendgrid_em4962" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "em4962.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_enterpriseenrollment" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "enterpriseenrollment.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["enterpriseenrollment.manage.microsoft.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_enterpriseenrollment2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "enterpriseregistration.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["enterpriseregistration.windows.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_lync" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "lyncdiscover.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["webdir.online.lync.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_msoid" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "msoid.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["clientconfig.microsoftonline-p.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_msoid" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "msoid.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["clientconfig.microsoftonline-p.net"]
}

resource "aws_route53_record" "ppo_route53_a_record_mta" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "mta-sts.ppo.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["d264sf26qsqfi.cloudfront.net."]
}

resource "aws_route53_record" "ppo_route53_cname_record_mta-sts" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_c8b092cc5e6b18d6d6b1785824fb5bf4.mta-sts.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_708974cacf749aaba82f164334e9e8b4.nhsllhhtvj.acm-validations.aws."]
}

resource "aws_route53_record" "ppo_route53_cname_record_sip" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "sip.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["sipdir.online.lync.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_www" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "www.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["ppo.gov.uk"]
}

resource "aws_route53_record" "ppo_route53_cname_record_www_acm" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_022696f67f214f732b546ed506caf325.www.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_a957df26df1020044886408df9f2ee24.jhztdrwbnw.acm-validations.aws."]
}










resource "aws_route53_record" "ppo_route53_a_record_connect" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "connect.ppo.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["178.239.100.157"]
}

resource "aws_route53_record" "ppo_route53_a_record_mail" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "mail.ppo.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["79.170.44.57"]
}

resource "aws_route53_record" "ppo_route53_a_record_mail2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "mail2.ppo.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["20.49.250.153"]
}

resource "aws_route53_record" "ppo_route53_a_record_mta" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "mta-sts.ppo.gov.uk"
  type    = "A"

  alias {
    name                   = "d17g7hcsgudvb4.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ppo_route53_mx_record_outlook" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "ppo.gov.uk"
  type    = "MX"
  ttl     = "300"
  records = ["10 ppo-gov-uk.mail.protection.outlook.com."]
}

resource "aws_route53_record" "ppo_route53_txt_record_main" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["MS=ms13510705", "moTzn29k+pERDZNgHyOtkGiR+/ckQKBhpJDwsM558yZCe4wETnTgQswUIVDMjxIQrRQyPxznbg0qy6o17si9qQ==", "v=spf1 include:spf.protection.outlook.com ip4:80.6.91.150 -all"]
}

resource "aws_route53_record" "ppo_route53_txt_record_asvdns" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_asvdns-332ae0bd-1b7a-46fd-825b-cfcbda0c2f0c.ppo.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["asvdns_feca725b-fbca-49e0-8928-f647ef79edb0"]
}

resource "aws_route53_record" "ppo_route53_txt_record_dmarc" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_dmarc.ppo.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DMARC1;p=quarantine;rua=mailto:PSm6GLjJ2Yt@dmarc-rua.mailcheck.service.ncsc.gov.uk;"]
}

resource "aws_route53_record" "ppo_route53_txt_record_mta_sts" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_mta-sts.ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=STSv1; id=61658d49bbc2aee51b11cebf1d37ae83"]
}

resource "aws_route53_record" "ppo_route53_txt_record_smtp" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_smtp._tls.ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "ppo_route53_txt_record_smtp2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_smtp._tls.imb.org.uk.ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "ppo_route53_cname_record_acm" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_5770ab00d5e1032ff7db591706b2f9a5.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_bd266e83797378e89bcbbc42c6974047.jhztdrwbnw.acm-validations.aws."]
}

resource "aws_route53_record" "ppo_route53_cname_record_mwn" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "mwn._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwn.domainkey.u25846363.wl114.sendgrid.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_mwn2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "mwn2._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwn2.domainkey.u25846363.wl114.sendgrid.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_mwo" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "mwo._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwo.domainkey.u26084809.wl060.sendgrid.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_mwo2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "mwo2._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwo2.domainkey.u26084809.wl060.sendgrid.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_selector1" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "selector1._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["selector1-ppo-gov-uk._domainkey.ppouk.onmicrosoft.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_selector2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "selector2._domainkey.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["selector2-ppo-gov-uk._domainkey.ppouk.onmicrosoft.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "autodiscover.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["autodiscover.outlook.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_sendgrid" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "em6039.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u25846363.wl114.sendgrid.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_sendgrid2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "em6531.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u26084809.wl060.sendgrid.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_enterpriseenrollment" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "enterpriseenrollment.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseenrollment.manage.microsoft.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_enterpriseregistration" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "enterpriseregistration.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseregistration.windows.net"]
}

resource "aws_route53_record" "ppo_route53_cname_record_lyncdiscover" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "lyncdiscover.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["webdir.online.lync.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_mta_sts2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_9e111899dbb1e73aed800dd796c849f4.mta-sts.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_529da6734664ecca58ad43f6298844fe.bkngfjypgb.acm-validations.aws."]
}

resource "aws_route53_record" "ppo_route53_cname_record_sipdir" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "sip.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["sipdir.online.lync.com"]
}

resource "aws_route53_record" "ppo_route53_cname_record_acm2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_2966249ff1f7d496b355eabc821707b3.www.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_054556e3de8c167ce984f414fdf89e12.jhztdrwbnw.acm-validations.aws."]
}

resource "aws_route53_record" "ppo_route53_srv_record_sipfed" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_sipfederationtls._tcp.ppo.gov.uk"
  type    = "SRV"
  ttl     = "3600"
  records = ["5061 1 100 sipfed.online.lync.com"]
}

resource "aws_route53_record" "ppo_route53_srv_record_sipdir" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_sip._tls.ppo.gov.uk"
  type    = "SRV"
  ttl     = "3600"
  records = ["443 1 100 sipdir.online.lync.com"]
}
