resource "aws_route53_zone" "route53_direct_zone" {
  name = "courtfines.direct.gov.uk"

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

resource "kubernetes_secret" "route53_direct_zone_sec" {
  metadata {
    name      = "route53-direct-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_direct_zone.zone_id
  }
}

resource "aws_route53_record" "aws_route53_record_prod" {
  name    = "courtfines.direct.gov.uk."
  zone_id = aws_route53_zone.route53_direct_zone.zone_id
  type    = "A"
  alias {
    zone_id                = "ZHURV8PSTC4K8"
    name                   = "dualstack.court-loadb-8mcola2l2by0-173012739.eu-west-2.elb.amazonaws.com."
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "aws_route53_record_cname_1" {
  name = "_975286e3bc1ca6804128ccd7c48c89ac.courtfines.direct.gov.uk."
  zone_id = aws_route53_zone.route53_direct_zone.zone_id
  type = "CNAME"
  ttl  = 60
  records = [
    "_308970e3209ac38b43bc563e49f2ccfc.hkvuiqjoua.acm-validations.aws."
  ]
}

resource "aws_route53_record" "aws_route53_record_cname_2" {
  name = "_fd42bbf0088b6b64004ae5ea5bb52833.courtfines.direct.gov.uk."
  zone_id = aws_route53_zone.route53_direct_zone.zone_id
  type = "CNAME"
  ttl  = 60
  records = [
    "_7ac7c4084a84f98a030c53171ecd735d.hkvuiqjoua.acm-validations.aws."
  ]
}
