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

resource "aws_route53_record" "ppo_route53_mx_record_outlook2" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "ppo.gov.uk"
  type    = "MX"
  ttl     = "300"
  records = ["0 ppo-gov-uk.mail.protection.outlook.com"]
}

resource "aws_route53_record" "ppo_route53_txt_record_servers" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["MS=ms15192188", "atlassian-domain-verification=eZYa71sfUYC3GKWDAnR6IDBAD7m0PkEaKKOYkM2cjWj8or0XT0PwqvFpqTLtaNby", "v=spf1 ip4:194.33.196.8/32 ip4:194.33.192.8/32 include:spf.protection.outlook.com include:servers.mcsv.net -all"]
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

resource "aws_route53_record" "ppo_route53_txt_record_miro" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "_miro_verification.ppo.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["miro-verification=9f7733fab8b41c5d9bbbf63c043f10dcfec77dab"]
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

resource "aws_route53_record" "ppo_route53_a_record_mta-sts" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "mta-sts.ppo.gov.uk"
  type    = "A"

  alias {
    name                   = "d264sf26qsqfi.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ppo_route53_cname_record_sip" {
  zone_id = aws_route53_zone.ppo_route53_zone.zone_id
  name    = "sip.ppo.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["sipdir.online.lync.com"]
}
