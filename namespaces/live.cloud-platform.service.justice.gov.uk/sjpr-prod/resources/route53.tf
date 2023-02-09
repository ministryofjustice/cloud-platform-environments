resource "aws_route53_zone" "sjpr_route53_zone" {
  name = var.domain

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner    
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "sjpr_route53_zone_sec" {
  metadata {
    name      = "sjpr_route53_zone_output"
    namespace = var.namespace
  }

  data = {
    zone_id   = aws_route53_zone.sjpr_route53_zone.zone_id
  }
}
