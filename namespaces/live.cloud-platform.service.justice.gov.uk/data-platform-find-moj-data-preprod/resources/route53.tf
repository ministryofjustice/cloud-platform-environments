resource "aws_route53_zone" "find_moj_preprod_zone" {
  name = var.domain

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

resource "kubernetes_secret" "find_moj_preprod_route53_zone_sec" {
  metadata {
    name      = "find-moj-data-preprod-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.find_moj_preprod_zone.zone_id
    nameservers = join("\n", aws_route53_zone.find_moj_preprod_zone.name_servers)
  }
}
