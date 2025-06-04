# This file contains the Route53 resources related to domains other than intranet.justice.gov.uk
resource "aws_route53_zone" "jac_intranet_service_justice_gov_uk_zone" {
  name = "jac.intranet.service.justice.gov.uk"

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

resource "kubernetes_secret" "route53_alt_zone_sec" {
  metadata {
    name      = "route53-alt-zone-output"
    namespace = var.namespace
  }

  data = {
    jac_zone_id      = aws_route53_zone.jac_intranet_service_justice_gov_uk_zone.zone_id
    jac_name_servers = join("\n", aws_route53_zone.jac_intranet_service_justice_gov_uk_zone.name_servers)
  }
}
