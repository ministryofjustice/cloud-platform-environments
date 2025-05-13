resource "aws_route53_zone" "cdn" {
  name = "cdn.service.justice.gov.uk"

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

resource "kubernetes_secret" "cdn_route53" {
  metadata {
    name      = "cdn-route53"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.cdn.zone_id
    nameservers = join("\n", aws_route53_zone.cdn.name_servers)
  }
}
