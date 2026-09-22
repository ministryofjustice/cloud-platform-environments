resource "aws_route53_zone" "monitoring" {
  name = "monitoring.data-platform.service.justice.gov.uk"

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

resource "kubernetes_secret" "monitoring_route53_zone" {
  metadata {
    name      = "monitoring-route53-zone"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.monitoring.zone_id
    nameservers = join("\n", aws_route53_zone.monitoring.name_servers)
  }
}
