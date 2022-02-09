resource "aws_route53_zone" "www_dev_cjsm_route53_zone" {
  name = "www.dev.cjsm.justice.gov.uk"

  tags = {
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "cjsm_route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    www_dev_zone_id      = aws_route53_zone.www_dev_cjsm_route53_zone.zone_id
    www_dev_name_servers = join("\n", aws_route53_zone.www_dev_cjsm_route53_zone.name_servers)
  }
}

