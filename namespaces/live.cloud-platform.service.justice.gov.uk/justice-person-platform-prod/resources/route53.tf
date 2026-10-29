resource "aws_route53_zone" "justice-person-platform-prod" {
  name = "justice-person-platform.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "justice-person-platform-prod_sec" {
  metadata {
    name      = "justice-person-platform-prod-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.justice-person-platform-prod.zone_id
    nameservers = join("\n", aws_route53_zone.justice-person-platform-prod.name_servers)
  }
}

# Sub-delegate dev/preprod inside the prod zone. These NS records cannot live in the parent
# service.justice.gov.uk zone: it is not authoritative below the justice-person-platform zone cut.
resource "aws_route53_record" "dev_ns_delegation" {
  zone_id = aws_route53_zone.justice-person-platform-prod.zone_id
  name    = "dev.justice-person-platform.service.justice.gov.uk"
  type    = "NS"
  ttl     = 300
  records = [
    "ns-1351.awsdns-40.org",
    "ns-2009.awsdns-59.co.uk",
    "ns-55.awsdns-06.com",
    "ns-648.awsdns-17.net",
  ]
}

resource "aws_route53_record" "preprod_ns_delegation" {
  zone_id = aws_route53_zone.justice-person-platform-prod.zone_id
  name    = "preprod.justice-person-platform.service.justice.gov.uk"
  type    = "NS"
  ttl     = 300
  records = [
    "ns-1028.awsdns-00.org",
    "ns-1590.awsdns-06.co.uk",
    "ns-37.awsdns-04.com",
    "ns-572.awsdns-07.net",
  ]
}
