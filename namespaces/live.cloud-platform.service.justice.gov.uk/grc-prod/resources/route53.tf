resource "aws_route53_zone" "route53_zone" {
  name = "gender-recognition.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_zone.zone_id
  }
}

resource "aws_route53_record" "apply_gender_recognition_certificate" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "apply-gender-recognition-certificate.service.gov.uk"
  type    = "CNAME"
  ttl  = 300
  records = [
    "d1ihfuni1rbt6y.cloudfront.net."
  ]
}

resource "aws_route53_record" "apply_gender_recognition_certificate" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_45bde841e2577492acdf0e9abee59ccc.apply-gender-recognition-certificate.service.gov.uk"
  type    = "CNAME"
  ttl  = 300
  records = [
    "_cfc22c9edb4982e95ae95abdc716c35c.bpxxncpwjz.acm-validations.aws."
  ]
}

resource "aws_route53_record" "apply_gender_recognition_certificate" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "admin.apply-gender-recognition-certificate.service.gov.uk"
  type    = "CNAME"
  ttl  = 300
  records = [
    "d38cgb3u1thx2u.cloudfront.net."
  ]
}

resource "aws_route53_record" "apply_gender_recognition_certificate" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_6dc57f9f5d57f6fcd214c3d256b9d209.admin.apply-gender-recognition-certificate.service.gov.uk"
  type    = "CNAME"
  ttl  = 300
  records = [
    "_4611cac725b87ca088506caa9dcb7b11.bpxxncpwjz.acm-validations.aws."
  ]
}

resource "aws_route53_record" "apply_gender_recognition_certificate" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "dashboard.apply-gender-recognition-certificate.service.gov.uk"
  type    = "CNAME"
  ttl  = 300
  records = [
    "grc-production-dashboard.london.cloudapps.digital."
  ]
}
