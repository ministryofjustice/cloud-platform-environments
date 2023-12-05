resource "aws_route53_zone" "casetracker_route53_zone" {
  name = "casetracker.justice.gov.uk"

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

resource "aws_route53_record" "aws_route53_record_prod_1" {
  name    = "casetracker.justice.gov.uk."
  zone_id = aws_route53_zone.casetracker_route53_zone.zone_id
  type    = "A"
  alias {
    zone_id                = "ZHURV8PSTC4K8"
    name                   = "dualstack.civil-loadb-qvbu457dp1b-1835055660.eu-west-2.elb.amazonaws.com."
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aws_route53_record_cname_1" {
  name    = "_490401529e094a46111033e0656c3ee9.casetracker.justice.gov.uk."
  zone_id = aws_route53_zone.casetracker_route53_zone.zone_id
  type    = "CNAME"
  ttl     = 60
  records = [
    "_aacbc806a088e7cdff9935f0c9958e9e.auiqqraehs.acm-validations.aws."
  ]
}

resource "kubernetes_secret" "casetracker_route53_zone_sec" {
  metadata {
    name      = "casetracker-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.casetracker_route53_zone.zone_id
  }
}
