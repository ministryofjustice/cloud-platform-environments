resource "aws_route53_zone" "mogaal_test_route53_zone" {
  name = var.domain

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment
    owner                  = var.team-name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "mogaal_test_route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.mogaal_test_route53_zone.zone_id
  }
}

