resource "aws_route53_zone" "icrir_route53_zone" {
  name = "icrir.independent-inquiry.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "icrir_route53_zone_sec" {
  metadata {
    name      = "icrir-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  }
}

resource "aws_route53_record" "icrir_route53_cname_www_record" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "www.icrir.independent-inquiry.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["icrir.independent-inquiry.uk"]
}

resource "aws_route53_record" "icrir_route53_txt" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "10800"
  records = ["v=spf1 ip4:194.32.29.0/24 ip4:194.32.31.0/24 ~all"]
}

resource "aws_route53_record" "icrir_route53_txt_dmarc" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "_dmarc.icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DMARC1; p=quarantine; rua=mailto:dmarc-rua@finance-ni.gov.uk,mailto:dmarc-rua@dmarc.service.gov.uk; adkim=r; aspf=r; pct=0; sp=none"]
}

resource "aws_route53_record" "icrir_route53_txt_belfast" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "belfast._domainkey.icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DKIM1; t=y; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0ggNmsVEbhdvEmeun/kktXh8wz8iiSgVAbH8PTTiRuchE65aCLA0VSSEtX7dN1P4MkB0d4vpFZckbiAA84Q4DgO9bdticphleyHo1tKPL\"\"++ZJSwTvPkGAE2xpl8SmefQpmhN4s3IKHEttvFYMUVqaxBY6dplJJNin4b2usXeZVMT7u3tn3UXGXtyCpn6cBoakC+LMcQDnfM11RAwY7nxe/IMUM69+/y5vjqiHmTUituVJsyfPqJy9TUKDmzirqH9qwQqT0vIQTBLEBY5RkQimT/Kx0vo2u04vcmcxPTKiYtQ4/xCMBWTPOA/Hh6MI839ydniaqfoXr2qVf7ED+oFoQIDAQAB;"]
}

resource "aws_route53_record" "icrir_route53_txt_asvdns" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "_asvdns-2ac0f8fb-9a02-4dfc-888e-7a804e21d5d2.icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["asvdns_597b5b92-f07e-4cca-95f2-f41a0b123faf"]
}

resource "aws_route53_record" "icrir_route53_mx" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "icrir.independent-inquiry.uk"
  type    = "MX"
  ttl     = "3600"
  records = ["10 mail1.nics.gov.uk.", "10 mail2.nics.gov.uk.", "10 mail3.nics.gov.uk.", "10 mail4.nics.gov.uk.", "10 mail5.nics.gov.uk.", "10 mail6.nics.gov.uk.", "10 mail7.nics.gov.uk.", "10 mail8.nics.gov.uk."]
}