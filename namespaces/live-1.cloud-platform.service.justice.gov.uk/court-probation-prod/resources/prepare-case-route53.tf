resource "aws_route53_zone" "prepare_case_route53_zone" {
  name = var.prepare-case-domain

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}

resource "kubernetes_secret" "prepare_case_route53_zone_sec" {
  metadata {
    name      = "prepare-case-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.prepare_case_route53_zone.zone_id
  }
}
