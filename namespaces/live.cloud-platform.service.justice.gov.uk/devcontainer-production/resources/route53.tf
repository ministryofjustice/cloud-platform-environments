resource "aws_route53_zone" "devcontainer_service_justice_gov_uk" {
  name = "devcontainer.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}


resource "aws_route53_record" "github_pages_user_guide" {
  zone_id = aws_route53_zone.devcontainer_service_justice_gov_uk.zone_id
  name    = "user-guide.devcontainer.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["ministryofjustice.github.io"]
}
