resource "aws_route53_zone" "laa_crime_apps_team_route53_zone" {
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

resource "kubernetes_secret" "laa_crime_apps_route53_zone_sec" {
  metadata {
    name      = "laa-crime-apps-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.laa_crime_apps_team_route53_zone.zone_id
  }
}
