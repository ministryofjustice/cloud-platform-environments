resource "aws_route53_zone" "pfl_cs_route53_zone" {
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

# add a txt record to the zone to verify ownership of the domain with Entra ID
resource "aws_route53_record" "entra_id_verification" {
  zone_id = aws_route53_zone.pfl_cs_route53_zone.zone_id
  name    = var.domain
  type    = "TXT"
  ttl     = 300
  records = [
    "MS=ms72370887"
  ]
}

resource "kubernetes_secret" "pfl_cs_route53_zone_sec" {
  metadata {
    name      = "pfl-cs-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.pfl_cs_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.pfl_cs_route53_zone.name_servers)
  }
}
