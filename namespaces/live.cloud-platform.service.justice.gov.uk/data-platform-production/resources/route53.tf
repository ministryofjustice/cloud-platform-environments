resource "aws_route53_zone" "data_platform_production_route53_zone" {
  name = "data-platform.service.justice.gov.uk"

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}

resource "kubernetes_secret" "data_platform_production_route53_zone_id" {
  metadata {
    name      = "cloud-platform-data-platform-production-route53-zone-id"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  }
}

resource "aws_route53_record" "data_platform_technical_documentation" {
  zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  name    = "technical-documentation.data-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["ministryofjustice.github.io."]
}
