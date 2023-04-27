resource "aws_route53_zone" "victimscommissioner_route53_zone" {
  name = "victimscommissioner.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "victimscommissioner_route53_zone_sec" {
  metadata {
    name      = "victimscommissioner-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  }
}

resource "aws_route53_record" "victimscommissioner_route53_a_record" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "victimscommissioner.org.uk"
  type    = "A"

  alias {
    name                   = "jotwp-loadb-1mbwraz503eq6-1769122100.eu-west-2.elb.amazonaws.com."
    zone_id                = "ZHURV8PSTC4K8"
    evaluate_target_health = false
  }
  
}

resource "aws_route53_record" "victimscommissioner_route53_mx_record_outlook" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "victimscommissioner.org.uk"
  type    = "MX"
  ttl     = "3600"
  records = ["0 victimscommissioner-org-uk.mail.protection.outlook.com"]
}

resource "aws_route53_record" "victimscommissioner_route53_txt_record_main" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "victimscommissioner.org.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["MS=ms22529871", "v=spf1 ip4:194.33.196.8/32 ip4:194.33.192.8/32 ip4:198.37.159.2 ip4:168.245.16.120 include:spf.protection.outlook.com -all", "atlassian-domain-verification=eZYa71sfUYC3GKWDAnR6IDBAD7m0PkEaKKOYkM2cjWj8or0XT0PwqvFpqTLtaNby"]
}

resource "aws_route53_record" "victimscommissioner_route53_txt_record_amazonses" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "_amazonses.victimscommissioner.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["u8FeCxutyRMlF+oIzgCA0t3WzLIRbbeagSpbtRByiPQ="]
}

resource "aws_route53_record" "victimscommissioner_route53_txt_record_domainkey" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "fp01._domainkey.victimscommissioner.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCN/Dnp6gO1PJVQgLljNpkkvVUH/G04C2QkC28j8ddX13V7MAvDWpCxnUfTPy8C27njUImSa8b2TwyeA0P2ONPHQhW652tSxZa0+VT2b5qRFhne3UigZEeKhix988mhlOTO+6PN4+JR7MPXSeE0iGGPWm8m4JsxeaVvwN0XC92yvQIDAQAB;"]
}

resource "aws_route53_record" "victimscommissioner_route53_txt_record_mta_sts" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "_mta-sts.victimscommissioner.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=STSv1; id=382e5b84ba072da4451a6081d72d60b4"]
}

resource "aws_route53_record" "victimscommissioner_route53_txt_record_smtp" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "_smtp._tls.victimscommissioner.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_acm" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "_763372be03a4e87a04610fa50b15adbd.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_a5501a920598b4c1cad73a7000cd5db6.tfmgdnztqk.acm-validations.aws."]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_dmarc" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "_dmarc.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_dmarc_ttp_policy.justice.gov.uk"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_dkim2" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "k2._domainkey.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["dkim2.mcsv.net"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_dkim3" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "k3._domainkey.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["dkim3.mcsv.net"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_onc" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "onc._domainkey.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["onc.domainkey.u32912322.wl073.sendgrid.net"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_onc2" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "onc2._domainkey.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["onc2.domainkey.u32912322.wl073.sendgrid.net"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_s1" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "s1._domainkey.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["s1.domainkey.u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_s2" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "s2._domainkey.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["s2.domainkey.u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_selector1" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "selector1._domainkey.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["selector1-victimscommissioner-org-uk._domainkey.JusticeUK.onmicrosoft.com"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_selector2" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "selector2._domainkey.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["selector2-victimscommissioner-org-uk._domainkey.JusticeUK.onmicrosoft.com"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "autodiscover.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["autodiscover.outlook.com"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_sendgrid" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "em3960.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_enterpriseenrollment" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "enterpriseenrollment.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseenrollment.manage.microsoft.com"]
}

resource "aws_route53_record" "victimscommissioner_route53_cname_record_enterpriseregistration" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "enterpriseregistration.victimscommissioner.org.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseregistration.windows.net"]
}

resource "aws_route53_record" "victimscommissioner_route53_srv_record_sipfed" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "_sipfederationtls._tcp.victimscommissioner.org.uk"
  type    = "SRV"
  ttl     = "3600"
  records = ["100 1 5061 sipfed.online.lync.com"]
}

resource "aws_route53_record" "victimscommissioner_route53_srv_record_sipdir" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "_sip._tls.victimscommissioner.org.uk"
  type    = "SRV"
  ttl     = "3600"
  records = ["100 1 443 sipdir.online.lync.com"]
}