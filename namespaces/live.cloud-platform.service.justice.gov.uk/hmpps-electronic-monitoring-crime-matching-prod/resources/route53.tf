resource "aws_route53_zone" "crime_matching_route53_zone" {
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

resource "kubernetes_secret" "crime_matching_route53_zone_sec" {
  metadata {
    name      = "crime-matching-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.crime_matching_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.crime_matching_route53_zone.name_servers)
  }
}