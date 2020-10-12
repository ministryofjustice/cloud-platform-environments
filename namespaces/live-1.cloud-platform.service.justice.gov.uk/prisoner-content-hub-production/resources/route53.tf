resource "aws_route53_zone" "content_hub_route53_zone" {
  name = "content-hub.prisoner.service.justice.gov.uk"

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "content_hub_route53_zone_secret" {
  metadata {
    name      = "${var.application}-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.content_hub_route53_zone.zone_id
  }
}
