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
  records = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAgCJ3gt3Pb2tqfcO+rMIRb7XcwoFrhpXHFSqHCxES+VOEZNc1h64sn9T+kmA9aO+5WXtgwn572U2ewLfeFJMLdBt/HW6PM/yWcCHr8jyzDE8cNhCDgmiANZ0+rEv+zuZVcxNsaoYTjijqcg1d\"\"MrO1k/I8kCrKZ/MCEY/x+0cy2G7XJ3btHxI81DCBhUvZjzATDvq2x/424dG7hzBCnDBclG14CzPEx75liRizwG+KXgkUpXlfDVXN2EVscDSWaMujvTu4M\"\"vask3USs3eOAuhF3Udy4stj5H5HPuxVcVZZprCxiDzRE90/aIpFLj/iLQroORpT0Xhq0IPl3xiCNoNxVQIDAQAB"]
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

resource "aws_route53_record" "niofficialhistory_route53_txt_record_asvdns" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "_asvdns-b8e60480-2998-4d55-9d68-f46933fc9e69.niofficialhistory.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_4754cadf-2f56-47bb-b5c1-b81196d9140b"]
}