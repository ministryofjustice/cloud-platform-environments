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

# tech docs DNS record
resource "aws_route53_record" "hmpps-tech-docs" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "tech-docs.hmpps.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["ministryofjustice.github.io."]
}

# Verify google search console
resource "aws_route53_record" "google" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "hmpps.service.justice.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=iTr6EZ5R2nbh-Uv8eo6VKOb_lkbaSFis63gO09GqxM0"]
}
