resource "aws_route53_zone" "ai_route53_zone" {
  name = var.domain

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "ai_route53_zone_sec" {
  metadata {
    name      = "ai-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.ai_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.ai_route53_zone.name_servers)
  }
}
