resource "aws_route53_zone" "cla_frontend_staging_route53_zone" {
  name = "laa-cla-frontend-staging.apps.live-1.cloud-platform.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure-support
  }
}

resource "kubernetes_secret" "cla_frontend_route53_zone_sec" {
  metadata {
    name      = "cla-frontend-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id   = aws_route53_zone.cla_frontend_staging_route53_zone.zone_id
  }
}