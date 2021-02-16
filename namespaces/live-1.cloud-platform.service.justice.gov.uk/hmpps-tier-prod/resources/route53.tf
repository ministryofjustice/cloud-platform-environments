resource "aws_route53_zone" "hmpps-tier-prod" {
  name = "hmpps-tier.hmpps.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "hmpps-tier_sec" {
  metadata {
    name      = "hmpps-tier-prod-zone-output"
    namespace = "hmpps-tier-prod"
  }

  data = {
    zone_id = aws_route53_zone.hmpps-tier-prod.zone_id
  }
}

