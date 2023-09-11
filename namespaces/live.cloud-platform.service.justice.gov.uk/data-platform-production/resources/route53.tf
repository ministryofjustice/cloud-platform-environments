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
