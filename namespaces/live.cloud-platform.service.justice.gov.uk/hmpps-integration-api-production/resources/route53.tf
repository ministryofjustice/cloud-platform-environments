resource "aws_route53_zone" "hosted_zone" {
  name = var.hosted_zone

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "hosted_zone_id" {
  metadata {
    name      = "route53-justice-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.hosted_zone.zone_id
  }
}