resource "aws_route53_zone" "justice-person-platform-prod" {
  name = "jpp.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "justice-person-platform-prod_sec" {
  metadata {
    name      = "justice-person-platform-prod-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.justice-person-platform-prod.zone_id
    nameservers = join("\n", aws_route53_zone.justice-person-platform-prod.name_servers)
  }
}
