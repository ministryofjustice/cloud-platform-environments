resource "aws_route53_zone" "route53_zone" {
  name = "moic.service.justice.gov.uk"

  tags = {
    application            = "MOIC"
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    short_zone_id = aws_route53_zone.route53_zone.zone_id
  }
}
