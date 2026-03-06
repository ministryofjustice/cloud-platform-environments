resource "aws_route53_zone" "cap_route53_zone" {
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

resource "kubernetes_secret" "cap_route53_zone_sec" {
  metadata {
    name      = "cap-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.cap_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.cap_route53_zone.name_servers)
  }
}

resource "aws_route53_zone" "pcap_zone" {
  name = "propose-child-arrangements-plan.service.gov.uk"

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "pcap_zone_sec" {
  metadata {
    name      = "pcap-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.pcap_zone.zone_id
    nameservers = join("\n", aws_route53_zone.pcap_zone.name_servers)
  }
}
