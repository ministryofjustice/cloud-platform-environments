resource "aws_route53_zone" "route53_zone" {
  name = "jacksapp-devs.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.owner    
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "jacksapp-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id   = aws_route53_zone.route53_zone.zone_id
  }
}
