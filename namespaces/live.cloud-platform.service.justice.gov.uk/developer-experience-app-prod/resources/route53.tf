resource "aws_route53_zone" "blueprint" {
  name = "blueprint.service.justice.gov.uk"

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

resource "kubernetes_secret" "blueprint_route53_zone" {
  metadata {
    name      = "blueprint-route53-zone"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.blueprint.zone_id
    nameservers = join("\n", aws_route53_zone.blueprint.name_servers)
  }
}
