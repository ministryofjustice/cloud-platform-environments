resource "aws_route53_zone" "omagh_route53_zone" {
  name = "omagh.independent-inquiry.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "omagh_route53_zone_sec" {
  metadata {
    name      = "omagh-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  }
}

resource "aws_route53_record" "omagh_route53_txt_asvdns" {
  zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  name    = "_asvdns-9bd05310-34f8-4f9e-abf7-9b2dd481be48.omagh.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["asvdns_96a49327-cddb-476d-8cbf-6d218630e474"]
}

resource "aws_route53_record" "omagh_route53_txt_main" {
  zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  name    = "omagh.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["MS=ms93403091", "v=spf1 ip4:194.32.29.0/24 ip4:194.32.31.0/24 ip4:52.208.126.243 ip4:52.31.106.198 ip4:198.154.180.128/26 include:_spf_euwest1.prod.hydra.sophos.com include:spf.protection.outlook.com -all", "sophos-domain-verification=6a45a9444a7172356133d8ca4413340c498c14a9"]
}

resource "aws_route53_record" "omagh_route53_txt_sophos" {
  zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  name    = "sophosfc18705ce4c84377aef9698ae91b1e72._domainkey.omagh.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwMPz8SPuwBMKzSvBxcp+lmEOkelEkdIT4oGhGtcr9a5LeSwC96Qd7+jZVjf2Vyhw/4s02bBKFY/C9uSicg41fcHpkwWsW2tA8eDPrhd\"\"Tyjnivik/niIHJmy+nMAzqO9LEK+2jzloc3pbgTU8TLl5c0BY2DY3zI/MjtsshdXXG+cfjaQqArNOlqDf2MtcFGbmOMlU86j/oMTdimcT/W9SBgBGnvymeHnOLBpf7pirEQXtjPGI1X6HgaltkNZNfRFXA7WrXb1ta+326D9orHU8RmKfLSXC0Zsm0KOedpZT5/hgvXdd672dL6J/NNDRoHTh+wrlkJp5qz17fUn75iEFMwIDAQAB"]
}

resource "aws_route53_record" "omagh_route53_txt_belfast" {
  zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  name    = "belfast._domainkey.omagh.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DKIM1; t=y; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0ggNmsVEbhdvEmeun/kktXh8wz8iiSgVAbH8PTTiRuchE65aCLA0VSSEtX7dN1P4MkB0d4vpFZckbiAA84Q4DgO9bdticphleyHo1tKPL\"\"++ZJSwTvPkGAE2xpl8SmefQpmhN4s3IKHEttvFYMUVqaxBY6dplJJNin4b2usXeZVMT7u3tn3UXGXtyCpn6cBoakC+LMcQDnfM11RAwY7nxe/IMUM69+/y5vjqiHmTUituVJsyfPqJy9TUKDmzirqH9qwQqT0vIQTBLEBY5RkQimT/Kx0vo2u04vcmcxPTKiYtQ4/xCMBWTPOA/Hh6MI839ydniaqfoXr2qVf7ED+oFoQIDAQAB;"]
}

resource "aws_route53_record" "omagh_route53_txt_dmarc" {
  zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  name    = "_dmarc.omagh.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DMARC1; p=quarantine; rua=mailto:dmarc-rua@dmarc.service.gov.uk; adkim=r; aspf=r; pct=100; sp=reject"]
}

resource "aws_route53_record" "omagh_route53_txt_smtp" {
  zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  name    = "_smtp._tls.omagh.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}


resource "aws_route53_record" "omagh_route53_mx_records" {
  zone_id = aws_route53_zone.omagh_route53_zone.zone_id
  name    = "omagh.independent-inquiry.uk"
  type    = "MX"
  ttl     = "300"
  records = ["10 mx-01-eu-west-1.prod.hydra.sophos.com", "20 mx-02-eu-west-1.prod.hydra.sophos.com"]
}
