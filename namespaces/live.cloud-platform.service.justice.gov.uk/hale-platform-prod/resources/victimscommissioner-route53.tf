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
  ttl     = "300"
  records = ["dualstack.jotwp-loadb-1mbwraz503eq6-1769122100.eu-west-2.elb.amazonaws.com."]
}

resource "aws_route53_record" "victimscommissioner_route53_mx_record" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "victimscommissioner.org.uk"
  type    = "MX"
  ttl     = "3600"
  records = ["0 victimscommissioner-org-uk.mail.protection.outlook.com"]
}

resource "aws_route53_record" "victimscommissioner_route53_txt_record_ms" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "victimscommissioner.org.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["MS=ms22529871"]
}

resource "aws_route53_record" "victimscommissioner_route53_txt_record_spf" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "victimscommissioner.org.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=spf1 ip4:194.33.196.8/32 ip4:194.33.192.8/32 ip4:198.37.159.2 ip4:168.245.16.120 include:spf.protection.outlook.com -all"]
}

resource "aws_route53_record" "victimscommissioner_route53_txt_record_atlassian" {
  zone_id = aws_route53_zone.victimscommissioner_route53_zone.zone_id
  name    = "victimscommissioner.org.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["atlassian-domain-verification=eZYa71sfUYC3GKWDAnR6IDBAD7m0PkEaKKOYkM2cjWj8or0XT0PwqvFpqTLtaNby"]
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