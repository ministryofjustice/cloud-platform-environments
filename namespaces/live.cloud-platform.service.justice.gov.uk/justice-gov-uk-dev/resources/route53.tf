resource "aws_route53_zone" "dev_justice_gov_uk_route53_zone" {
  name = "dev.justice.gov.uk"

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    www_dev_zone_id      = aws_route53_zone.dev_justice_gov_uk_route53_zone.zone_id
    www_dev_name_servers = aws_route53_zone.dev_justice_gov_uk_route53_zone.name_servers
  }
}
