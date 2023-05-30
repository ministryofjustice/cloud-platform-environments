resource "aws_route53_zone" "check_clients_details_using_hmrc_data_route53_zone" {
  name = "check-clients-details-using-hmrc-data.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "assure_hmrc_data_route_53_zone_sec" {
  metadata {
    name      = "assure-hmrc-data-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.check_clients_details_using_hmrc_data_route53_zone.zone_id
  }
}

