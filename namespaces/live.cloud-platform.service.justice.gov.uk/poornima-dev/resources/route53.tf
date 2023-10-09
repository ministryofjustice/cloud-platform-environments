resource "aws_route53_zone" "poornima_dev_route53_zone" {
  name = "pk-dev.et.cloud-platform.service.justice.gov.uk."

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = "Cloud Platform Team"
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "pk_dev_route53_zone_sec" {
  metadata {
    name      = "pkdev-route53-zone-output"
    namespace = var.namespace
  }
}
