resource "aws_route53_zone" "fum_route53_zone" {
  name = "find-unclaimed-court-money.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "fum_route53_zone_sec" {
  metadata {
    name      = "fum-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.fum_route53_zone.zone_id
  }
}
