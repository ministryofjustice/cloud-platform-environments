resource "aws_route53_zone" "nscc_metabase_route53_zone" {
  name = var.domain

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.owner
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "nscc_metabase_route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.nscc_metabase_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.nscc_metabase_route53_zone.name_servers)
  }
}