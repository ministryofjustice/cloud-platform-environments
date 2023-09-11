resource "aws_route53_zone" "justicejobs_route53_zone" {
  name = "jobs.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "justicejobs_route53_zone_sec" {
  metadata {
    name      = "justicejobs-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.justicejobs_route53_zone.zone_id
  }
}

resource "aws_route53_record" "justicejobs_route53_a_record" {
  zone_id = aws_route53_zone.justicejobs_route53_zone.zone_id
  name    = "jobs.justice.gov.uk"
  type    = "A"
  ttl     = "300"

  alias {
    name                   = "dualstack.justi-loadb-sq9lna0p02ao-206129886.eu-west-2.elb.amazonaws.com."
    zone_id                = ""
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "justicejobs_route53_txt_record_goog" {
  zone_id = aws_route53_zone.justicejobs_route53_zone.zone_id
  name    = "jobs.justice.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=ajvfy_2DMm2yiEMIzFgwTFjZ_MjqGZ3_mIusMQS93sY"]
}

resource "aws_route53_record" "justicejobs_route53_cname_record_acm" {
  zone_id = aws_route53_zone.justicejobs_route53_zone.zone_id
  name    = "_32e00677b9d5518d832c3dea41eb2222.jobs.justice.gov.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_4f02d2a3ed7c6bb1093897f47f79399d.mzlfeqexyx.acm-validations.aws."]
}

resource "aws_route53_record" "justicejobs_route53_cname_record_sendgrid1" {
  zone_id = aws_route53_zone.justicejobs_route53_zone.zone_id
  name    = "s1._domainkey.jobs.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["s1.domainkey.u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "justicejobs_route53_cname_record_sendgrid2" {
  zone_id = aws_route53_zone.justicejobs_route53_zone.zone_id
  name    = "s2._domainkey.jobs.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["s2.domainkey.u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "justicejobs_route53_cname_record_sendgrid3" {
  zone_id = aws_route53_zone.justicejobs_route53_zone.zone_id
  name    = "em2023.jobs.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u2320754.wl005.sendgrid.net"]
}