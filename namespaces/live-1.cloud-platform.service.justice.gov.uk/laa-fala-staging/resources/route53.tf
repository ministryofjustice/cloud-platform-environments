resource "aws_route53_zone" "route53_zone" {
  name = "staging.find-legal-advice.justice.gov.uk"

  tags = {
    business-unit    = var.business-unit
    application      = var.application
    is-production    = var.is-production
    environment-name = var.environment-name
    owner            = var.team_name
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_zone.zone_id
  }
}
