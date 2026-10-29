resource "aws_route53_zone" "cjsm_route53_zone" {
  name = "cjsm.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "cjsm_route53_zone_sec" {
  metadata {
    name      = "cjsm-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
    nameservers = join(",", aws_route53_zone.cjsm_route53_zone.name_servers)
  }
}
resource "aws_route53_record" "cjsm_route53_txt_record_main" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "cjsm.justice.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["MS=ms43148106", "v=spf1 include:spf.protection.outlook.com include:_spf.salesforce.com -all"]
}

resource "aws_route53_record" "cjsm_route53_txt_record_sfdv" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "_sfdv.cjsm.justice.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["00d1t000000dwuveac._sfdv.cjsm.justice.gov.uk"]
}

resource "aws_route53_record" "cjsm_route53_mx_record" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "cjsm.justice.gov.uk"
  type    = "MX"
  ttl     = "3600"
  records = ["0 cjsm-justice-gov-uk.mail.protection.outlook.com."]
}

resource "aws_route53_record" "cjsm_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "autodiscover.cjsm.justice.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["autodiscover.outlook.com."]
}

resource "aws_route53_record" "cjsm_route53_cname_record_salesforce_dkim" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "cjsm.justice.gov.uk._domainkey.cjsm.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["cjsm.justice.gov.uk.wdx2rf.custdkim.salesforce.com."]
}

resource "aws_route53_record" "cjsm_route53_cname_record_salesforce03_dkim" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "salesforce03._domainkey.cjsm.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["salesforce03.u763xu.custdkim.salesforce.com."]
}

resource "aws_route53_record" "cjsm_route53_cname_record_sfam_dkim" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "sfam7ffde25qt4fumk6uyoooxkzci2o5._domainkey.cjsm.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["sfam7ffde25qt4fumk6uyoooxkzci2o5.dkim.amazonses.com"]
}

resource "aws_route53_record" "cjsm_route53_cname_record_ocm_dkim" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "ocm7xkb2o2ufcybmuz53yuxh3kp3nq4s._domainkey.cjsm.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["ocm7xkb2o2ufcybmuz53yuxh3kp3nq4s.dkim.amazonses.com"]
}

resource "aws_route53_record" "cjsm_route53_cname_record_svpp_dkim" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "svppnmonwx6une3pcugpjw4etbsxdo33._domainkey.cjsm.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["svppnmonwx6une3pcugpjw4etbsxdo33.dkim.amazonses.com"]
}

resource "aws_route53_record" "cjsm_route53_mx_record_mail" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "mail.cjsm.justice.gov.uk"
  type    = "MX"
  ttl     = "300"
  records = ["10 feedback-smtp.eu-west-2.amazonses.com"]
}

resource "aws_route53_record" "cjsm_route53_txt_record_mail" {
  zone_id = aws_route53_zone.cjsm_route53_zone.zone_id
  name    = "mail.cjsm.justice.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 ip4:24.110.96.96 ip4:24.110.96.97 -all"]
}