resource "aws_route53_zone" "justiceinspectorates_route53_zone" {
  name = "justiceinspectorates.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "justiceinspectorates_route53_zone" {
  metadata {
    name      = "justiceinspectorates-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.justiceinspectorates_route53_zone.zone_id
  }
}

resource "aws_route53_record" "justiceinspectorates_route53_cname_record_assets" {
  zone_id = aws_route53_zone.justiceinspectorates_route53_zone.zone_id
  name    = "assets-hmicfrs.justiceinspectorates.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["dzm0ui1toev7.cloudfront.net"]
}

resource "aws_route53_record" "justiceinspectorates_route53_cname_record_hmicfrs" {
  zone_id = aws_route53_zone.justiceinspectorates_route53_zone.zone_id
  name    = "hmicfrs.justiceinspectorates.gov.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["hmicfrs.b-cdn.net"]
}

resource "aws_route53_record" "justiceinspectorates_route53_cname_record_hmiprobationeforms" {
  zone_id = aws_route53_zone.justiceinspectorates_route53_zone.zone_id
  name    = "hmiprobationeforms.justiceinspectorates.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["hmiprobationeforms.live.bangdynamics.com"]
}

resource "aws_route53_record" "justiceinspectorates_route53_cname_record_hmicfrs_acm" {
  zone_id = aws_route53_zone.justiceinspectorates_route53_zone.zone_id
  name    = "_4db237fe0679b5055c854f480873647d.hmicfrs.justiceinspectorates.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["_2326da8b5885263e394ef0fdfa48c4b5.hnyzmxtzsz.acm-validations.aws"]
}

resource "aws_route53_record" "justiceinspectorates_route53_cname_record_assets_acm" {
  zone_id = aws_route53_zone.justiceinspectorates_route53_zone.zone_id
  name    = "_1bb6da7fc8ff3c4473d3f446d943f10a.assets-hmicfrs.justiceinspectorates.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["_13864bc89cfac506d876bcba6914a2ba.kmjqhnbgnp.acm-validations.aws"]
}

resource "aws_route53_record" "justiceinspectorates_route53_mx_record_main" {
  zone_id = aws_route53_zone.justiceinspectorates_route53_zone.zone_id
  name    = "justiceinspectorates.gov.uk"
  type    = "MX"
  ttl     = "3600"
  records = ["10 mx1.bangdynamics.com", "20 mx2.bangdynamics.com"]
}

resource "aws_route53_record" "hmiprisons_route53_cname_record_dkim" {
  zone_id = aws_route53_zone.justiceinspectorates_route53_zone.zone_id
  name    = "litesrv._domainkey.hmiprisons.justiceinspectorates.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["litesrv._domainkey.mlsend.com"]
}

resource "aws_route53_record" "hmiprisons_route53_txt_record_spf" {
  zone_id = aws_route53_zone.justiceinspectorates_route53_zone.zone_id
  name    = "hmiprisons.justiceinspectorates.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = [
    "\"v=spf1 include:_spf.mlsend.com ip4:194.33.196.8/32 ip4:194.33.192.8/32 include:spf.protection.outlook.com -all\""
  ]
}

resource "aws_route53_record" "hmiprisons_route53_txt_record_verification" {
  zone_id = aws_route53_zone.justiceinspectorates_route53_zone.zone_id
  name    = "hmiprisons.justiceinspectorates.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["\"mailerlite-domain-verification=042a934207bc9e97f86a70915a70ca23e0378b35\""]
}


