resource "aws_route53_zone" "laa_crime_apps_team_route53_zone" {
  name = var.domain

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "laa_crime_apps_route53_zone_sec" {
  metadata {
    name      = "laa-crime-apps-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.laa_crime_apps_team_route53_zone.zone_id
  }
}

resource "aws_route53_record" "bc_prod" {
  name    = "_1t62whbcnt4ej6waw9jbruabyybsj63.laa-benefit-checker.service.justice.gov.uk"
  zone_id = aws_route53_zone.laa_crime_apps_team_route53_zone.zone_id
  type    = "CNAME"
  records = ["dcv.digicert.com"]
  ttl     = "300"
}

resource "aws_route53_record" "bc_prod_ext" {
  name    = "_1t62whbcnt4ej6waw9jbruabyybsj63.www.laa-benefit-checker.service.justice.gov.uk"
  zone_id = aws_route53_zone.laa_crime_apps_team_route53_zone.zone_id
  type    = "CNAME"
  records = ["dcv.digicert.com"]
  ttl     = "300"
}

resource "aws_route53_record" "bc_uat" {
  name    = "_2txda07ippujatlt6lwrmtg03o007ne.uat.laa-benefit-checker.service.justice.gov.uk"
  zone_id = aws_route53_zone.laa_crime_apps_team_route53_zone.zone_id
  type    = "CNAME"
  records = ["dcv.digicert.com"]
  ttl     = "300"
}

resource "aws_route53_record" "bc_uat_ext" {
  name    = "_2txda07ippujatlt6lwrmtg03o007ne.www.uat.laa-benefit-checker.service.justice.gov.uk"
  zone_id = aws_route53_zone.laa_crime_apps_team_route53_zone.zone_id
  type    = "CNAME"
  records = ["dcv.digicert.com"]
  ttl     = "300"
}
