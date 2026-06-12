resource "aws_route53_zone" "llm_gateway" {
  name = "llm-gateway.development.data-platform.service.justice.gov.uk"

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

resource "kubernetes_secret" "llm_gateway_route53" {
  metadata {
    name      = "llm-gateway-route53"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.llm_gateway.zone_id
    nameservers = join("\n", aws_route53_zone.llm_gateway.name_servers)
  }
}
