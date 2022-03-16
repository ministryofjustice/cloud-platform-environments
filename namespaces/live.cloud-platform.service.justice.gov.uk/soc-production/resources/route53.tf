resource "aws_route53_zone" "soc_route53_zone" {
  name = "hmcts-risk-assurance-operating-controls.service.justice.gov.uk"

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

resource "kubernetes_secret" "soc_route53_zone_sec" {
  metadata {
    name      = "soc-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.soc_route53_zone.zone_id
  }
}