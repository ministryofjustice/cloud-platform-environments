resource "aws_route53_zone" "sif_route53_zone" {
  name = "hmcts-sif-reporting-tool.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.owner
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "sif_route53_zone_sec" {
  metadata {
    name      = "sif-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.sif_route53_zone.zone_id
  }
}