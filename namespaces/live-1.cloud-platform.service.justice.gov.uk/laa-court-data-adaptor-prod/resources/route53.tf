resource "aws_route53_zone" "laa_crime_apps_team_route53_zone" {
  name = "court-data-adaptor.service.justice.gov.uk"

  tags = {
    business-unit          = "Legal Aid Agency"
    application            = "LAA Court Data Adaptor"
    is-production          = "true"
    environment-name       = "production"
    owner                  = "LAA Crime Apps Team: laa-crime-apps@digital.justice.gov.uk"
    infrastructure-support = "laa-crime-apps@digital.justice.gov.uk"
  }
}

resource "kubernetes_secret" "laa_crime_apps_route53_zone_sec" {
  metadata {
    name      = "laa-crime-apps-route53-zone-output"
    namespace = "laa-court-data-adaptor-prod"
  }

  data = {
    zone_id = aws_route53_zone.laa_crime_apps_team_route53_zone.zone_id
  }
}
