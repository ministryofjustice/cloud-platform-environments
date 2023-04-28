resource "aws_route53_zone" "route53_zone" {
  name = "review-criminal-legal-aid.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_zone.zone_id
  }
}
