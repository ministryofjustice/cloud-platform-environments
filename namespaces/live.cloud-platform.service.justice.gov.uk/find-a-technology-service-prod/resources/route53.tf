resource "aws_route53_zone" "find_a_digital_service" {
  name = var.domain

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "find_a_digital_service_route53_zone" {
  metadata {
    name      = "find-a-digital-service-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.find_a_digital_service.zone_id
    nameservers = join("\n", aws_route53_zone.find_a_digital_service.name_servers)
  }
}
