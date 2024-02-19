resource "aws_route53_zone" "victimandwitnessinformation_route53_zone" {
  name = "victimandwitnessinformation.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "victimandwitnessinformation_route53_zone_sec" {
  metadata {
    name      = "victimandwitnessinformation-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.victimandwitnessinformation_route53_zone.zone_id
  }
}
