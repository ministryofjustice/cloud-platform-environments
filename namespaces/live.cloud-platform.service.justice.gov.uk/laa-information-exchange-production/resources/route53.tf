resource "aws_route53_zone" "infox_route53_zone" {
  name = var.domain

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

data "aws_route53_zone" "cloud_platform_shared_zone" {
  name         = "live.cloud-platform.service.justice.gov.uk"
  private_zone = false
}

resource "kubernetes_secret" "infox_route53_zone_secret" {
  metadata {
    name      = "infox-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.infox_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.infox_route53_zone.name_servers)
  }
}

resource "aws_route53_record" "alt_prod" {
  ttl     = 300
  type    = "CNAME"
  name    = "infox.apps.live.cloud-platform.service.justice.gov.uk"
  zone_id = data.aws_route53_zone.cloud_platform_shared_zone.zone_id
  records = ["infox.service.justice.gov.uk"]
}