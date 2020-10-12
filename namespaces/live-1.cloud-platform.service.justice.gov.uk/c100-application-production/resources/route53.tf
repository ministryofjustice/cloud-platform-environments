resource "aws_route53_zone" "route53_zone_short" {
  name = "c100.service.justice.gov.uk"

  tags = {
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "aws_route53_zone" "route53_zone_long" {
  name = "apply-to-court-about-child-arrangements.service.justice.gov.uk"

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
    short_zone_id = aws_route53_zone.route53_zone_short.zone_id
    long_zone_id  = aws_route53_zone.route53_zone_long.zone_id
  }
}

