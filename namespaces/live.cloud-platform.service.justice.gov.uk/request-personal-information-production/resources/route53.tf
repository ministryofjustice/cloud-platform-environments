resource "aws_route53_zone" "request_personal_information_route53_zone" {
  name = var.domain

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

resource "kubernetes_secret" "request_personal_information_route53_zone_sec" {
  metadata {
    name      = "request_personal_information_route53_zone_sec"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.request_personal_information_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.request_personal_information_route53_zone.name_servers)
  }
}
