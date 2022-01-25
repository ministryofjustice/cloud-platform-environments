resource "aws_route53_zone" "route53_zone" {
  name = "prison.service.justice.gov.uk"

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}


# prod DNS record for Azure based Prison API
resource "aws_route53_record" "prison-api-prod" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "api.prison.service.justice.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["20.39.161.101"]
}


# preprod DNS record for Azure based Prison API
resource "aws_route53_record" "prison-api-preprod" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "api-preprod.prison.service.justice.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["20.39.160.142"]
}

# dev DNS record for Azure based Prison API
resource "aws_route53_record" "prison-api-dev" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "api-dev.prison.service.justice.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["20.39.160.233"]
}

# stage DNS record for Azure based Prison API
resource "aws_route53_record" "prison-api-stage" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "api-stage.prison.service.justice.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["20.39.160.251"]
}
