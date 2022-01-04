resource "aws_route53_zone" "crime_portal_mirror_gateway_route53_zone" {
  name = var.crime-portal-mirror-gateway-domain

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}

resource "kubernetes_secret" "crime_portal_mirror_gateway_route53_zone_sec" {
  metadata {
    name      = "crime-portal-mirror-gateway-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    sone_id = aws_route53_zone.crime_portal_mirror_gateway_route53_zone.zone_id
  }
}
