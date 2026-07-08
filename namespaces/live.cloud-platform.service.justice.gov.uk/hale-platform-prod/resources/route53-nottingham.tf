resource "aws_route53_zone" "nottingham_route53_zone" {
  name = "nottingham.independent-inquiry.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "nottingham_route53_zone_sec" {
  metadata {
    name      = "nottingham-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.nottingham_route53_zone.zone_id
    nameservers = join(",", aws_route53_zone.nottingham_route53_zone.name_servers)
  }
}