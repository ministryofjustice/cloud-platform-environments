resource "aws_route53_zone" "courts_local_scorecard_route53_zone" {
  name = "criminal-justice-scorecard.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "courts_local_scorecard_route53_zone_sec" {
  metadata {
    name      = "courts-local-scorecard-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.courts_local_scorecard_route53_zone.zone_id
  }
}
