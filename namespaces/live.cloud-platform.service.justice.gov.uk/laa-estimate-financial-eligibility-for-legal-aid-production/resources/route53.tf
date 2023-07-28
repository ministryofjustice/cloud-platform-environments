resource "aws_route53_zone" "eligibility_team_route53_zone" {
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

resource "kubernetes_secret" "eligibility_team_route53_zone" {
  metadata {
    name      = "eligibility-team-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id   = aws_route53_zone.eligibility_team_route53_zone.zone_id
    nameservers = join(", ", aws_route53_zone.eligibility_team_route53_zone.name_servers)
  }
}

