# Zone to be used by multiple services in various namespaces
resource "aws_route53_zone" "route53_zone_hmpps" {
  name = "hmpps.service.justice.gov.uk"

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}


# prod zone delegated to Azure based Nomis API
resource "aws_route53_record" "hmpps-auth-prod" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "sign-in.hmpps.service.justice.gov.uk"
  type    = "NS"
  ttl     = "30"

  records = [
    "ns1-04.azure-dns.com.",
    "ns2-04.azure-dns.net.",
    "ns3-04.azure-dns.org.",
    "ns4-04.azure-dns.info."
  ]
}


# preprod zone delegated to Azure based Nomis API
resource "aws_route53_record" "hmpps-auth-preprod" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "sign-in-preprod.hmpps.service.justice.gov.uk"
  type    = "NS"
  ttl     = "30"

  records = [
    "ns1-05.azure-dns.com.",
    "ns2-05.azure-dns.net.",
    "ns3-05.azure-dns.org.",
    "ns4-05.azure-dns.info."
  ]
}

# dev zone delegated to Azure based Nomis API
resource "aws_route53_record" "hmpps-auth-dev" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "sign-in-dev.hmpps.service.justice.gov.uk"
  type    = "NS"
  ttl     = "30"

  records = [
    "ns1-01.azure-dns.com.",
    "ns2-01.azure-dns.net.",
    "ns3-01.azure-dns.org.",
    "ns4-01.azure-dns.info."
  ]
}

# stage zone delegated to Azure based Nomis API
resource "aws_route53_record" "hmpps-auth-stage" {
  zone_id = aws_route53_zone.route53_zone_hmpps.zone_id
  name    = "sign-in-stage.hmpps.service.justice.gov.uk"
  type    = "NS"
  ttl     = "30"

  records = [
    "ns1-07.azure-dns.com.",
    "ns2-07.azure-dns.net.",
    "ns3-07.azure-dns.org.",
    "ns4-07.azure-dns.info."
  ]
}
