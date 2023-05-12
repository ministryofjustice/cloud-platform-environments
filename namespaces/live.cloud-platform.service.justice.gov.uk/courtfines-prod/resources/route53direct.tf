Addresource "aws_route53_zone" "route53_direct_zone" {
  name = "courtfines.direct.gov.uk"

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

resource "kubernetes_secret" "route53_direct_zone_sec" {
  metadata {
    name      = "route53-direct_zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_direct_zone.zone_id
  }
}
