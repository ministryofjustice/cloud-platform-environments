resource "aws_route53_zone" "route53_zone" {
  name = "prisonvisits.service.gov.uk"

  tags = {
    business-unit          = "HMPPS"
    application            = "PVB"
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_zone.zone_id
  }
}

resource "aws_route53_zone" "route53_justice_zone" {
  name = "prisonvisits.service.justice.gov.uk"

  tags = {
    business-unit          = "HMPPS"
    application            = "PVB"
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_justice_zone_sec" {
  metadata {
    name      = "route53-justice-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_justice_zone.zone_id
  }
}

