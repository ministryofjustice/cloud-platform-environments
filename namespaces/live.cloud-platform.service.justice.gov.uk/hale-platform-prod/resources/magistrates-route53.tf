resource "aws_route53_zone" "magistrates_route53_zone" {
  name = "magistrates.judiciary.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "magistrates_route53_zone_sec" {
  metadata {
    name      = "magistrates-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.magistrates_route53_zone.zone_id
  }
}

resource "aws_route53_record" "magistrates_route53_a_record" {
  zone_id = aws_route53_zone.magistrates_route53_zone.zone_id
  name    = "magistrates.judiciary.uk"
  type    = "A"

  alias {
    name                   = "dualstack.jotwp-loadb-1mbwraz503eq6-1769122100.eu-west-2.elb.amazonaws.com."
    zone_id                = "ZHURV8PSTC4K8"
    evaluate_target_health = false
  }

}

resource "aws_route53_record" "magistrates_route53_a_record_apply" {
  zone_id = aws_route53_zone.magistrates_route53_zone.zone_id
  name    = "apply.magistrates.judiciary.uk"
  type    = "A"
  ttl     = "300"
  records = ["18.130.183.123"]
}

resource "aws_route53_record" "magistrates_route53_cname_record_acm" {
  zone_id = aws_route53_zone.magistrates_route53_zone.zone_id
  name    = "_6f0e92da46509e479f24cc2bad43c06f.magistrates.judiciary.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_3ba2c01f2ad818f8e254df3786b6222e.zdxcnfdgtt.acm-validations.aws."]
}
