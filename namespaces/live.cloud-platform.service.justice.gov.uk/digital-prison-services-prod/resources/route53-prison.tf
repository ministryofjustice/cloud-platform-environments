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
