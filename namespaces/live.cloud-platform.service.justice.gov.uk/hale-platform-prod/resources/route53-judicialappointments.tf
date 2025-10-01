resource "aws_route53_zone" "judicialappointments_route53_zone" {
  name = "judicialappointments.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "judicialappointments_route53_zone_sec" {
  metadata {
    name      = "judicialappointments-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
    nameservers = join(",", aws_route53_zone.judicialappointments_route53_zone.name_servers)
  }
}


resource "aws_route53_record" "judicialappointments_route53_a_record_mta" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "mta-sts.judicialappointments.gov.uk"
  type    = "A"

  alias {
    name                   = "dopvhi9dsi04k.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = true
  }
}

name=dopvhi9dsi04k.cloudfront.net.; evaluate-target-health=true; hosted-zone-id=Z2FDTNDATAQYW2; type=A

resource "aws_route53_record" "judicialappointments_route53_txt_record_main" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "judicialappointments.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["MS=ms55245335", "atlassian-domain-verification=eZYa71sfUYC3GKWDAnR6IDBAD7m0PkEaKKOYkM2cjWj8or0XT0PwqvFpqTLtaNby", "v=spf1 ip4:194.33.196.8/32 ip4:194.33.192.8/32  include:spf.protection.outlook.com -all", "miro-verification=9f7733fab8b41c5d9bbbf63c043f10dcfec77dab", "openai-domain-verification=dv-gXY7MAiAOTilu9e4RVzySI3U"]
}

resource "aws_route53_record" "judicialappointments_route53_txt_record_asvdns" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "_asvdns-dbc20bcc-93bd-4de9-a347-c6f3ee0fe0cb.judicialappointments.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_c3033785-ef9f-432b-ae81-93d0b6eaac0e"]
}

resource "aws_route53_record" "judicialappointments_route53_txt_record_github_challenge" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "_github-challenge-moj-analytical-services.judicialappointments.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["f19c18b5ab"]
}

resource "aws_route53_record" "judicialappointments_route53_txt_record_mta" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "_mta-sts.judicialappointments.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=STSv1; id=c7d26af1a5ba18e6d7e8dcfb2e1f67ef"]
}

resource "aws_route53_record" "judicialappointments_route53_txt_record_smtp" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "_smtp._tls.judicialappointments.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "judicialappointments_route53_txt_record_fp" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "fp01._domainkey.judicialappointments.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCN/Dnp6gO1PJVQgLljNpkkvVUH/G04C2QkC28j8ddX13V7MAvDWpCxnUfTPy8C27njUImSa8b2TwyeA0P2ONPHQhW652tSxZa0+VT2b5qRFhne3UigZEeKhix988mhlOTO+6PN4+JR7MPXSeE0iGGPWm8m4JsxeaVvwN0XC92yvQIDAQAB;"]
}

resource "aws_route53_record" "judicialappointments_route53_mx_record" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "judicialappointments.gov.uk"
  type    = "MX"
  ttl     = "3600"
  records = ["0 judicialappointments-gov-uk.mail.protection.outlook.com"]
}

resource "aws_route53_record" "judicialappointments_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "autodiscover.judicialappointments.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["autodiscover.outlook.com."]
}

resource "aws_route53_record" "judicialappointments_route53_cname_record_mta_sts" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "_6351f8e182881f77d161743e5cf255f9.mta-sts.judicialappointments.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_4292f047d8178ad0c173fcae7c96e32c.rdnyqppgxp.acm-validations.aws."]
}

resource "aws_route53_record" "judicialappointments_route53_cname_record_dmarc" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "_dmarc.judicialappointments.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_dmarc_ttp_policy.justice.gov.uk"]
}

resource "aws_route53_record" "judicialappointments_route53_cname_record_enterpriseenrollment" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "enterpriseenrollment.judicialappointments.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseenrollment.manage.microsoft.com"]
}

resource "aws_route53_record" "judicialappointments_route53_cname_record_enterpriseregistration" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "enterpriseregistration.judicialappointments.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseregistration.windows.net"]
}

resource "aws_route53_record" "judicialappointments_route53_cname_record_msoid" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "msoid.judicialappointments.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["clientconfig.microsoftonline-p.net"]
}

resource "aws_route53_record" "judicialappointments_route53_cname_record_selector1" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "selector1._domainkey.judicialappointments.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["selector1-judicialappointments-gov-uk._domainkey.justiceuk.onmicrosoft.com"]
}

resource "aws_route53_record" "judicialappointments_route53_cname_record_selector2" {
  zone_id = aws_route53_zone.judicialappointments_route53_zone.zone_id
  name    = "selector2._domainkey.judicialappointments.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["selector2-judicialappointments-gov-uk._domainkey.justiceuk.onmicrosoft.com"]
}