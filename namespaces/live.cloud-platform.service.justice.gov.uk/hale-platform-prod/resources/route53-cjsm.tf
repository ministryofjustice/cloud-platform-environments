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


