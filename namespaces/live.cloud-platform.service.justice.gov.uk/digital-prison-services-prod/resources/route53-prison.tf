resource "aws_route53_zone" "route53_zone" {
  name = "prison.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}


# prod DNS record for Azure based Prison API
resource "aws_route53_record" "prison-api-prod" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "api.prison.service.justice.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["51.141.55.10"]
}


# preprod DNS record for Azure based Prison API
resource "aws_route53_record" "prison-api-preprod" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "api-preprod.prison.service.justice.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["52.142.149.4"]
}
