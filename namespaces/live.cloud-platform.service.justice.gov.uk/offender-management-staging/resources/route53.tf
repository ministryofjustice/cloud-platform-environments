resource "aws_route53_zone" "offender-management-allocation-manager" {
  name = "moic-dev.service.justice.gov.uk"

  tags = {
    business-unit          = "Cloud Platform"
    application            = "moic"
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = "cloud platform"
    infrastructure-support = "cloud platform"
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "moic_route53_zone_sec" {
  metadata {
    name      = "moic-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.moic.zone_id
  }
}

