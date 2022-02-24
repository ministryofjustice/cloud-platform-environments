resource "aws_route53_zone" "fum_route53_zone" {
  name = "find-unclaimed-court-money.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.owner
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "fum_route53_zone_sec" {
  metadata {
    name      = "fum-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.fum_route53_zone.zone_id
  }
}


resource "aws_route53_record" "add_arecord_production" {
  name    = "find-unclaimed-court-money.service.justice.gov.uk"
  zone_id = aws_route53_zone.fum_route53_zone.zone_id
  type    = "A"
  records = ["dualstack.ubi-p-loadb-1rk7d55h8z4t3-1469044134.eu-west-2.elb.amazonaws.com."]
  ttl     = "300"
}

resource "aws_route53_record" "add_cname_validation" {
  name    = "_39556719e8d565ea45417d38b40889c7.find-unclaimed-court-money.service.justice.gov.uk"
  zone_id = aws_route53_zone.fum_route53_zone.zone_id
  type    = "CNAME"
  records = ["_06c52dec40633865541b0ff381d9eeb1.chvvfdvqrj.acm-validations.aws."]
  ttl     = "300"
}
resource "aws_route53_record" "add_cname_validation_www" {
  name    = "_6f2592c897ce1cb57321ce86823bba01.www.find-unclaimed-court-money.service.justice.gov.uk"
  zone_id = aws_route53_zone.fum_route53_zone.zone_id
  type    = "CNAME"
  records = ["_b889b9713a37c39694f437333e017428.chvvfdvqrj.acm-validations.aws."]
  ttl     = "300"
}
