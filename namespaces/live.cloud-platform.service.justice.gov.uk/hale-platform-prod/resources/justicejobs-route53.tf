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

resource "aws_route53_record" "justicejobs_route53_txt_record_goog" {
  zone_id = aws_route53_zone.justicejobs_route53_zone.zone_id
  name    = "jobs.justice.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=ajvfy_2DMm2yiEMIzFgwTFjZ_MjqGZ3_mIusMQS93sY"]
}

resource "aws_route53_record" "justicejobs_route53_txt_record_dkim" {
  zone_id = aws_route53_zone.justicejobs_route53_zone.zone_id
  name    = "dkim.justicejobs._domainkey.jobs.justice.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1UkRKlZ/DmId+dcvZ8O0w9fD6W56dVO6sDVzjvj\"\"ZXJAmnknQgdSRGWIH6NgrJodrwkcR8AwCGPhYQtdbkHHD9UIXffJOzjA30c24QBD92iI0cWYpDSJ6wu6NlB+m5512MhUbeNe0ZfRgcY2SViZqY21VUnVbavAjQAfnj6ouDfnwoKBNFfdhTzznaKB2\"\"wzivY6Bprx5x0KUx4wll0HbswgZdefbOhdnrVtC1/yrh64f92CJC4f1j8GZWeK3Of+JOs6oDraHGGPBowQssseEjmrwuMn/7Fus0KpdED2NEmoBAo7BqqGflFO5YfpnGFNeJVhrhnLU067NWORVFM7//FwIDAQAB"]
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
