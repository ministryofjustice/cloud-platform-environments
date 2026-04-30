resource "aws_route53_zone" "route53_zone" {
  name = "developer-portal.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_route53_record" "dev_subdomain_ns" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "dev.developer-portal.service.justice.gov.uk"
  type    = "NS"
  ttl     = 600
  records = ["ns-1230.awsdns-25.org", "ns-1738.awsdns-25.co.uk", "ns-228.awsdns-28.com", "ns-835.awsdns-40.net"]
}

resource "kubernetes_secret" "route53_zone_output" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.route53_zone.name_servers)
  }
}