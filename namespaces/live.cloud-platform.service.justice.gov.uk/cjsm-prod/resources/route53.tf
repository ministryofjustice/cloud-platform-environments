resource "aws_route53_zone" "www_cjsm_route53_zone" {
  name = "www.cjsm.justice.gov.uk"

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
    www_zone_id      = aws_route53_zone.www_cjsm_route53_zone.zone_id
    www_name_servers = join("\n", aws_route53_zone.www_cjsm_route53_zone.name_servers)
  }
}
