resource "aws_route53_zone" "route53_justice_zone" {
  name = "immigrationappealsonline.justice.gov.uk"

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

resource "kubernetes_secret" "route53_justice_zone_sec" {
  metadata {
    name      = "route53-justice-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_justice_zone.zone_id
  }
}

resource "aws_route53_record" "aws_route53_record_prod_1" {
  name    = "immigrationappealsonline.justice.gov.uk."
  zone_id = aws_route53_zone.route53_justice_zone.zone_id
  type    = "A"
  alias {
    zone_id                = "Z32O12XQLNTSW2"
    name                   = "iacfees-prod-alb-waf-1928234551.eu-west-1.elb.amazonaws.com."
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aws_route53_record_cname_1" {
  name    = "_bbde749af95f9db428c5643e2a4bb710.immigrationappealsonline.justice.gov.uk."
  zone_id = aws_route53_zone.route53_justice_zone.zone_id
  type    = "CNAME"
  ttl     = 60
  records = [
    "_aeb80b3f8f3963e3506d87496778dd1f.dlgthlwgnp.acm-validations.aws."
  ]
}