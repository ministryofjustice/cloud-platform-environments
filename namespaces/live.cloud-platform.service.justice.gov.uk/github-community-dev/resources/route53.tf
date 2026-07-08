resource "aws_route53_zone" "route53_zone" {
  name = "github-community-dev.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_zone_output" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.route53_zone.name_servers)
  }
}
