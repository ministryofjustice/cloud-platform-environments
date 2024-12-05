resource "aws_route53_zone" "staging_justice_gov_uk_route53_zone" {
  # Note. `stage` not the typical `staging` subdomain, because that was unavailable.
  name = "stage.justice.gov.uk"

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
    zone_id      = aws_route53_zone.staging_justice_gov_uk_route53_zone.zone_id
    name_servers = join("\n", aws_route53_zone.staging_justice_gov_uk_route53_zone.name_servers)
  }
}
