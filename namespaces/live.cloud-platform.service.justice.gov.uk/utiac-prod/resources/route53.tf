resource "aws_route53_zone" "route53_justice_zone" {
  name = "tribunalsdecisions.service.gov.uk"

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
  name    = "tribunalsdecisions.service.gov.uk."
  zone_id = aws_route53_zone.route53_justice_zone.zone_id
  type    = "A"
  alias {
    zone_id                = "ZHURV8PSTC4K8"
    name                   = "dualstack.dtsla-utiac-lb-prod-1989357889.eu-west-1.elb.amazonaws.com."
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aws_route53_record_cname_1" {
  name    = "_8ba7ec9e63838fe3e3d630ce965706b3.tribunalsdecisions.service.gov.uk."
  zone_id = aws_route53_zone.route53_justice_zone.zone_id
  type    = "CNAME"
  ttl     = 60
  records = [
    "_f26e09f08db0cba807d529c8f96282ad.nxntxfsdbd.acm-validations.aws."
  ]
}