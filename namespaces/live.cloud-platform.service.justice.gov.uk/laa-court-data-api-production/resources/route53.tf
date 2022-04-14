resource "aws_route53_zone" "cdapi_route53_zone" {
  name = var.domain

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

resource "kubernetes_secret" "cdapi_route53_zone_sec" {
  metadata {
    name      = "cdapi-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.cdapi_route53_zone.zone_id
    name_servers = join("\n", aws_route53_zone.cdapi_route53_zone.name_servers)
  }
}