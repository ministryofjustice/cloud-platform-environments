resource "aws_route53_zone" "route53_justice_zone" {
  name = "courtfines.justice.gov.uk"

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

resource "aws_route53_record" "aws_route53_record_prod_2" {
  name    = "courtfines.justice.gov.uk."
  zone_id = aws_route53_zone.route53_justice_zone.zone_id
  type    = "A"
  alias {
    zone_id                = "ZHURV8PSTC4K8"
    name                   = "dualstack.court-loadb-8mcola2l2by0-173012739.eu-west-2.elb.amazonaws.com."
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aws_route53_record_cname_4" {
  name    = "_2a1a4e48c8d67e03e4dd87b69d34149c.courtfines.justice.gov.uk."
  zone_id = aws_route53_zone.route53_justice_zone.zone_id
  type    = "CNAME"
  ttl     = 60
  records = [
    "_6c5fbab046ead6c93bd45423c9084efd.hkvuiqjoua.acm-validations.aws."
  ]
}

resource "aws_route53_record" "aws_route53_record_cname_5" {
  name    = "_3aac79b257286a0493e2380447480616.courtfines.justice.gov.uk."
  zone_id = aws_route53_zone.route53_justice_zone.zone_id
  type    = "CNAME"
  ttl     = 300
  records = [
    "_adad5fb8a7388fa6c39cc5b39528cd6e.hkvuiqjoua.acm-validations.aws."
  ]
}
