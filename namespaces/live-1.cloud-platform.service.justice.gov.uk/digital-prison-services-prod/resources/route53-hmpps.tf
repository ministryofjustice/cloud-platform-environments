# Zone to be used by multiple services in various namespaces
resource "aws_route53_zone" "route53_zone_hmpps" {
  name = "hmpps.service.justice.gov.uk"

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
resource "aws_route53_record" "hmpps-auth-prod" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "sign-in.hmpps.service.justice.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["20.39.161.101"]
}


# preprod DNS record for Azure based Prison API
resource "aws_route53_record" "hmpps-auth-preprod" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "sign-in-preprod.hmpps.service.justice.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["20.39.160.142"]
}

# dev DNS record for Azure based Prison API
resource "aws_route53_record" "hmpps-auth-dev" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "sign-in-dev.hmpps.service.justice.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["20.39.160.233"]
}

# stage DNS record for Azure based Prison API
resource "aws_route53_record" "hmpps-auth-stage" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "sign-in-stage.hmpps.service.justice.gov.uk"
  type    = "A"
  ttl     = "30"
  records = ["20.39.160.251"]
}
