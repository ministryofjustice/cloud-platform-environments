resource "aws_route53_zone" "sop-derived-organogram-prod" {
  name = "moj-org-chart.service.justice.gov.uk"

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

resource "kubernetes_secret" "sop-derived-organogram-prod_sec" {
  metadata {
    name      = "sop-derived-organogram-prod-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.sop-derived-organogram-prod.zone_id
    nameservers = join("\n", aws_route53_zone.sop-derived-organogram-prod.name_servers)
  }
}
