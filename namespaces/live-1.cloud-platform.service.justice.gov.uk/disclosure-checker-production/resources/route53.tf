resource "aws_route53_zone" "route53_zone" {
  name = "check-when-to-disclose-caution-conviction.service.justice.gov.uk"

  tags = {
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "aws_route53_zone" "route53_zone_gds" {
  name = "check-when-to-disclose-caution-conviction.service.gov.uk"

  tags = {
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.route53_zone.zone_id
    gds_zone_id = aws_route53_zone.route53_zone_gds.zone_id
  }
}
