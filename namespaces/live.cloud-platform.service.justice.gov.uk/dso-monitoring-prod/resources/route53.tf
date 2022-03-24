resource "aws_route53_zone" "mod-platform-monitoring" {
  name = "mod-platform-monitoring.service.justice.gov.uk"

  tags = {
    business-unit    = var.business_unit
    application      = var.application
    is-production    = var.is_production
    environment-name = var.environment
    owner            = var.team_name
    namespace        = var.namespace
  }
}

resource "kubernetes_secret" "mod-platform-monitoring" {
  metadata {
    name      = "mod-platform-monitoring"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.mod-platform-monitoring.zone_id
  }
}
