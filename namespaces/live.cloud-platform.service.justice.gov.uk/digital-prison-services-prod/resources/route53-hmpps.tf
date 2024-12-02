# Zone to be used by multiple services in various namespaces
resource "aws_route53_zone" "route53_zone_hmpps" {
  name = "hmpps.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

# Verify google search console
resource "aws_route53_record" "google" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "hmpps.service.justice.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=iTr6EZ5R2nbh-Uv8eo6VKOb_lkbaSFis63gO09GqxM0"]
}
