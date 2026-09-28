resource "aws_route53_zone" "sop-derived-organogram-preprod" {
  name = "moj-org-chart-preprod.service.justice.gov.uk"

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

resource "kubernetes_secret" "sop-derived-organogram-preprod_sec" {
  metadata {
    name      = "sop-derived-organogram-preprod-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.sop-derived-organogram-preprod.zone_id
    nameservers = join("\n", aws_route53_zone.sop-derived-organogram-preprod.name_servers)
  }
}
