resource "aws_route53_zone" "data_platform_production_route53_zone" {
  name = "data-platform.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "aws_route53_zone" "data_platform_apps_alpha_route53_zone" {
  name = "apps.alpha.mojanalytics.xyz"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "aws_route53_zone" "data_platform_test_alpha_route53_zone" {
  name = "test.alpha.mojanalytics.xyz"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

/* Delegating to data-platform-development */
resource "aws_route53_record" "data_platform_development_zone" {
  zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  name    = "development.data-platform.service.justice.gov.uk"
  type    = "NS"
  ttl     = "600"
  records = ["ns-1741.awsdns-25.co.uk.", "ns-446.awsdns-55.com.", "ns-1406.awsdns-47.org.", "ns-952.awsdns-55.net."]
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
