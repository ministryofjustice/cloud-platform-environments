resource "aws_route53_zone" "hmpps-interventions-prod" {
  name = "refer-monitor-intervention.service.justice.gov.uk"

  tags = {
    team-name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "hmpps-interventions-prod_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = "hmpps-interventions-prod"
  }

  data = {
    zone_id = aws_route53_zone.hmpps-interventions-prod.zone_id
  }
}
