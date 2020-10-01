resource "aws_route53_zone" "moj_online_route53_zone" {
  name = var.zone_name

  tags = {
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "moj_online_route53_zone_sec" {
  metadata {
    name      = "moj-online-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.moj_online_route53_zone.zone_id
  }
}
