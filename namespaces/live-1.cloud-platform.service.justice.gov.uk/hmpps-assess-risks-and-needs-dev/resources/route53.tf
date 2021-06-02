resource "aws_route53_zone" "hmpps_assess_risks_and_needs_dev_route53_zone" {
  name = var.domain

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "${var.namespace}-route53-zone"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.hmpps_assessments_route53_zone.zone_id
  }
}
