resource "aws_route53_zone" "courts_local_scorecard_route53_zone" {
  name = "criminal-justice-scorecard.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
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

resource "aws_route53_zone" "criminal_justice_delivery_data_dashboards_route53_zone" {
  name = "criminal-justice-delivery-data-dashboards.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "criminal_justice_delivery_data_dashboards_route53_zone_sec" {
  metadata {
    name      = "criminal-justice-delivery-data-dashboards-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.criminal_justice_delivery_data_dashboards_route53_zone.zone_id
  }
}
