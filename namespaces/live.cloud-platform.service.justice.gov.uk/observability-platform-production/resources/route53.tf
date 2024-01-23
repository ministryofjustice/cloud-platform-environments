resource "aws_route53_zone" "observability_platform_service_justice_gov_uk" {
  name = "observability-platform.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "aws_route53_record" "github_pages" {
  zone_id = aws_route53_zone.observability_platform_service_justice_gov_uk.zone_id
  name    = "observability-platform.service.justice.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
}
