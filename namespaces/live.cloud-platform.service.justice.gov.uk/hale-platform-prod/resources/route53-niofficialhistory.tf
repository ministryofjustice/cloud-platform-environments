resource "aws_route53_zone" "niofficialhistory_route53_zone" {
  name = "niofficialhistory.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "niofficialhistory_route53_zone_sec" {
  metadata {
    name      = "niofficialhistory-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
    nameservers = join(",", aws_route53_zone.niofficialhistory_route53_zone.name_servers)
  }
}

resource "aws_route53_record" "niofficialhistory_route53_cname_record_google" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "cnqopo3wv3ip.niofficialhistory.org.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["gv-twbi4p5vtx43zw.dv.googlehosted.com"]
}

resource "aws_route53_record" "niofficialhistory_route53_mx_record_main" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "niofficialhistory.org.uk"
  type    = "MX"
  ttl     = "300"
  records = ["20 mx-02-eu-west-1.prod.hydra.sophos.com.", "10 mx-01-eu-west-1.prod.hydra.sophos.com."]
}

resource "aws_route53_record" "niofficialhistory_route53_txt_record_main" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "niofficialhistory.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=qgUm8Z7PTfhp2VkwYKKlo6-GFomNQu2QmgiU-aZ5ADo"]
}

resource "aws_route53_record" "niofficialhistory_route53_txt_record_dmarc" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "_dmarc.niofficialhistory.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=quarantine; rua=mailto:dmarc-rua@finance-ni.gov.uk,mailto:dmarc-rua@dmarc.service.gov.uk; adkim=r; aspf=r; pct=0; sp=none"]
}

resource "aws_route53_record" "niofficialhistory_route53_txt_domainkey" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "sophos2de752f943a0484491f5d897972a8f61._domainkey.niofficialhistory.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuxlfukIPlNxBCe+RnfTXDhk1pub8rqscdImMHH679S9u0OQrm8+cumW0yr1ceqTgn2HBVcA83m+o+9CRUq2fvpxXDndhuD\"\"laqJi4uu7XFlsxK6oHxetyRTXmYCNq236JvK2etkfUDVmfKv3YkiW22Hqepqa3SG8bSC4xPmqlWW5ZQBKfvlYqMhxraznNhe72d
mkJpZERp7qBYgkkfZnsj4HNqsnPP8\"\"i+a5XDW16OGnsMs9xhQkaU8Z6IaWCE8sjn4sxnn/CkPaj+ogQL1ehbgKOJwkVi14cthBGT92WStRIy7oKx7VnncdOk+a7wTVbuZA5qmwknCckNxAZA3vXrBQIDAQAB"]
}
