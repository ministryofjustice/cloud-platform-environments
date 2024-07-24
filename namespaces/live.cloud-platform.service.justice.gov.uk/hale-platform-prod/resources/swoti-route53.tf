resource "aws_route53_zone" "swoti_route53_zone" {
  name = "seewhatsontheinside.com"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "swoti_route53_zone_sec" {
  metadata {
    name      = "swoti-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.swoti_route53_zone.zone_id
  }
}


resource "aws_route53_zone" "swoti_uk_route53_zone" {
  name = "seewhatsontheinside.co.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "swoti_uk_route53_zone_sec" {
  metadata {
    name      = "swoti-uk-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.swoti_uk_route53_zone.zone_id
  }
}