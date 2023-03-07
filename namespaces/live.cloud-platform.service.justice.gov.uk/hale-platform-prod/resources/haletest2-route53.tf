resource "aws_route53_zone" "haletest2_route53_zone" {
  name = haletest2.service.justice.gov.uk 

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}

resource "kubernetes_secret" "haletest2_route53_zone_sec" {
  metadata {
    name      = "haletest2-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.haletest2_route53_zone.zone_id
  }
}
