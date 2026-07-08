resource "aws_route53_zone" "finucane_route53_zone" {
  name = "finucane.independent-inquiry.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "finucane_route53_zone_sec" {
  metadata {
    name      = "finucane-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.finucane_route53_zone.zone_id
    nameservers = join(",", aws_route53_zone.finucane_route53_zone.name_servers)
  }
}

resource "aws_route53_record" "finucane_route53_mx_records" {
  zone_id = aws_route53_zone.finucane_route53_zone.zone_id
  name    = "finucane.independent-inquiry.uk"
  type    = "MX"
  ttl     = "300"
  records = [
    "10 mx-01-eu-west-1.prod.hydra.sophos.com.",
    "20 mx-02-eu-west-1.prod.hydra.sophos.com.",
  ]
}

resource "aws_route53_record" "finucane_route53_dmarc" {
  zone_id = aws_route53_zone.finucane_route53_zone.zone_id
  name    = "_dmarc.finucane.independent-inquiry.uk"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DMARC1; p=reject; pct=100; adkim=r; aspf=r; rua=mailto:dmarc-rua@finance-ni.gov.uk,mailto:7c8cbf1d@inbox.ondmarc.com; ruf=mailto:7c8cbf1d@inbox.ondmarc.com; fo=1; ri=3600"
  ]
}

resource "aws_route53_record" "finucane_route53_spf" {
  zone_id = aws_route53_zone.finucane_route53_zone.zone_id
  name    = "finucane.independent-inquiry.uk"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 ip4:194.32.29.0/24 ip4:194.32.31.0/24 ip4:52.208.126.243 ip4:52.31.106.198 ip4:198.154.180.128/26 include:_spf_euwest1.prod.hydra.sophos.com include:spf.protection.outlook.com -all"
  ]
}

resource "aws_route53_record" "finucane_route53_dkim" {
  zone_id = aws_route53_zone.finucane_route53_zone.zone_id
  name    = "sophos6ccbafd5a548420e95312e0473634265._domainkey.finucane.independent-inquiry.uk"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAugfVMdz1tPmlB2oEiIhVLeZnRUzge+doPPTmRvbmhtkPzFGA+mkV49eRXbakmS4pTUgb4DF2A3M5d",
    "uqLDbhxUDG9Jmg7Yavq6qqPYACVai/pPws+mekRMjlUhSxxa6tiqgWRd5Aw+b154uslY4GzaZCrioKd/l0WCKYD3pE2TQlo0u7eev9ViU7NtrieJiEbpfbhAeJx3DkI4zP991sdu",
    "cdz0p7q9Qk4ApuxwDbPnkXiZFWKKcf9KBNu3OYbQkVLAalwjihxKqSMPnbRLZMGbuS3/9DW/cHH9zRoKGS7yJjUVVHJ3clYTn7xzD8PFcwqoFVfPDnCnuOIniLrtgl51QIDAQAB;"
  ]
}

