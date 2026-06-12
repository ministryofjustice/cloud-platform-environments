resource "aws_route53_zone" "pecs_route53_zone" {
  name = "pecs-contract-guide.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "pecs_route53_zone_sec" {
  metadata {
    name      = "pecs-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.pecs_route53_zone.zone_id
    nameservers = join(",", aws_route53_zone.pecs_route53_zone.name_servers)
  }
}


