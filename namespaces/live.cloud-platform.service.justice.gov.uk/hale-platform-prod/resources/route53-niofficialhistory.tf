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

resource "aws_route53_record" "niofficialhistory_route53_mx_record" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "niofficialhistory.org.uk"
  type    = "MX"
  ttl     = "300"
  records = ["1 smtp.google.com"]
}

resource "aws_route53_record" "niofficialhistory_route53_cname_record_google" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "cnqopo3wv3ip.niofficialhistory.org.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["gv-twbi4p5vtx43zw.dv.googlehosted.com"]
}

resource "aws_route53_record" "niofficialhistory_route53_txt_record_main" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "niofficialhistory.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=qgUm8Z7PTfhp2VkwYKKlo6-GFomNQu2QmgiU-aZ5ADo", "v=spf1 include:_spf.google.com -all"]
}

resource "aws_route53_record" "niofficialhistory_route53_txt_record_google_domainkey" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "google._domainkey.niofficialhistory.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0fDudnI0ylnq9j023KY8ZTP8eIvqb75Hnc47J7/ou6WyiIbAB5u2dShCS0GJue0d4LcIMvZaMm41RTSdSH2nvTO/hx2oJoFhHfVIdNeLKfVEpSLKrbSNy\"\"GP9Zt9S3Zkp0pcCoC03rQlMbBD68ZLC0/cRPZ3gUvA4zoGEcPX1EjIFZm2nONV2s4H3HDV30C2W6xUDOYgg6UtQJKFMQBqYGDWboSZfjBhWoLI5sIlCU6soqiie1X2YmdzUTOuGKsmxos06zLCszIfL\"\"Nap2EKDFoneIsSqbneLXjrjcSX6Q7HzQlbG6EmHeRWAfhlP9V67viEdiQMRjqqaFcHesMdhySQIDAQAB"]
}

resource "aws_route53_record" "niofficialhistory_route53_txt_record_dmarc" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "_dmarc.niofficialhistory.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=reject; pct=100; adkim=r; aspf=r; rua=mailto:7c8cbf1d@inbox.ondmarc.com; ruf=mailto:7c8cbf1d@inbox.ondmarc.com; fo=1; ri=3600"]
}

resource "aws_route53_record" "niofficialhistory_route53_txt_record_smtp" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "_smtp._tls.niofficialhistory.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}
