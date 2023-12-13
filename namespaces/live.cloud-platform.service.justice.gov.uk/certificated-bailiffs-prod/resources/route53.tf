resource "aws_route53_zone" "certbailiff_route53_zone" {
  name = "certificatedbailiffs.justice.gov.uk"

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

resource "kubernetes_secret" "certbailiff_route53_zone_sec" {
  metadata {
    name      = "certbailiff-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.certbailiff_route53_zone.zone_id
  }
}

resource "aws_route53_record" "aws_route53_record_prod_1" {
  name    = "certificatedbailiffs.justice.gov.uk."
  zone_id = aws_route53_zone.certbailiff_route53_zone.zone_id
  type    = "A"
  alias {
    zone_id                = "ZHURV8PSTC4K8"
    name                   = "certi-LoadB-Q2S48NUAQSC6-1478330638.eu-west-2.elb.amazonaws.com."
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aws_route53_record_cname_1" {
  name    = "_5cf8079a9b824596abdbbcb00d30073c.certificatedbailiffs.justice.gov.uk."
  zone_id = aws_route53_zone.certbailiff_route53_zone.zone_id
  type    = "CNAME"
  ttl     = 60
  records = [
    "_121059a8dce2ffbcf7aee539544f7f7e.htgdxnmnnj.acm-validations.aws."
  ]
}
