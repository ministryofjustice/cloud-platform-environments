resource "aws_route53_zone" "observability" {
  name = "observability.analytical-platform.service.justice.gov.uk"

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

resource "kubernetes_secret" "observability_route53_zone" {
  metadata {
    name      = "observability-route53-zone"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.observability.zone_id
    nameservers = join("\n", aws_route53_zone.observability.name_servers)
  }
}
