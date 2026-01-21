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

resource "aws_route53_record" "icrir_route53_cname_careers" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "careers.icrir.independent-inquiry.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["ICRIRweb.eploy.net"]
}

resource "aws_route53_record" "icrir_route53_cname_dkim" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "icrirproddkim._domainkey.icrir.independent-inquiry.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["icrirproddkim.r7qj3j.custdkim.salesforce.com"]
}

resource "aws_route53_record" "icrir_route53_cname_dkim2" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "icrirproddikimalt._domainkey.icrir.independent-inquiry.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["icrirproddikimalt.em8b7l.custdkim.salesforce.com"]
}

resource "aws_route53_record" "icrir_route53_cname_careers_dkim" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "bumryojo75ntntp5fsghu4b4svbylp7j._domainkey.careers.icrir.independent-inquiry.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["bumryojo75ntntp5fsghu4b4svbylp7j.dkim.amazonses.com"]
}

resource "aws_route53_record" "icrir_route53_cname_careers_dkim2" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "lxkcit7oelayzoy7vzpo2a2nf2tul5eu._domainkey.careers.icrir.independent-inquiry.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["lxkcit7oelayzoy7vzpo2a2nf2tul5eu.dkim.amazonses.com"]
}

resource "aws_route53_record" "icrir_route53_cname_careers_dkim3" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "xmuskwhyp3hir7wsn2nmzg7xzv5bewd7._domainkey.careers.icrir.independent-inquiry.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["xmuskwhyp3hir7wsn2nmzg7xzv5bewd7.dkim.amazonses.com"]
}

resource "aws_route53_record" "icrir_route53_cname_info_dkim" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "infoicrirproddkim.domainkey.info.icrir.independent-inquiry.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["infoicrirproddkim.i2gn2l.custdkim.salesforce.com"]
}

resource "aws_route53_record" "icrir_route53_cname_info_dkimalt" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "infoicrirproddikimalt.domainkey.info.icrir.independent-inquiry.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["infoicrirproddikimalt.a8734u.custdkim.salesforce.com"]
}

resource "aws_route53_record" "icrir_route53_txt" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 ip4:194.32.29.0/24 ip4:194.32.31.0/24 ip4:52.208.126.243 ip4:52.31.106.198 ip4:198.154.180.128/26 include:_spf_euwest1.prod.hydra.sophos.com include:_spf.salesforce.com include:spf.protection.outlook.com -all", "sophos-domain-verification=64f22b1b53453a1059db6e455503ed554f02e94d"]
}

resource "aws_route53_record" "icrir_route53_txt_sophos" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "sophosf3bd95765ac040c5885192c8f338b89c._domainkey.icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn0zVpXF3yitKcLbCcQkoObTE0zTRFYHsSix/abMrRKH6EfU98bgMOYppzzW9E7UHbx6eOud9HjUM1u5PoPniYVOE1HaGCuZ59R\"\"W/Gy9ZajrWQG4nzujyObKFsrijmhTmlMNTyg07SY0x8zwB59ToXrzaXLHzsFtECsfO1I5QU0Qa87L6XJC4OmToRdqplvD6BXQ2ZYmMrgYme9mQVEjZ/0b1UfAvA32ocxlINbBEkpWoWQaJYkn86b31rvpcc+l7v09W3YbRkiFw5zrX031bVCahSN+pdz8Z99fCRtdOdwFJleSZDEfWYIb0swfM/W1jqBnuFbu65WgSsT/Ewzky5QIDAQAB"]
}

resource "aws_route53_record" "icrir_route53_txt_dmarc" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "_dmarc.icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DMARC1; p=quarantine; pct=100; adkim=r; aspf=r; rua=mailto:dmarc-rua@finance-ni.gov.uk,mailto:7c8cbf1d@inbox.ondmarc.com; ruf=mailto:7c8cbf1d@inbox.ondmarc.com; fo=1; ri=3600"]
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

resource "aws_route53_record" "icrir_route53_txt_asvdns3" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "_asvdns-fc26cf25-cac3-4ed5-91dd-bc49ab167c7a.careers.icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["asvdns_b872b912-99d4-47f9-b1a8-82d64481e883"]
}

resource "aws_route53_record" "icrir_route53_txt_smtp" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "_smtp._tls.icrir.independent-inquiry.uk" 
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]  
}

resource "aws_route53_record" "icrir_route53_txt_careers_spf" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "eploymail.careers.icrir.independent-inquiry.uk" 
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 include:amazonses.com -all"]  
}

resource "aws_route53_record" "icrir_route53_txt_careers_dmarc" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "_dmarc.careers.icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DMARC1; p=reject; rua=mailto:dmarc-rua@dmarc.service.gov.uk,mailto:dmarc-rua@finance-ni.gov.uk; adkim=r; aspf=r; pct=100"]
}

resource "aws_route53_record" "icrir_route53_txt_info" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "info.icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 ip4:194.32.29.0/24 ip4:194.32.31.0/24 ip4:52.208.126.243 ip4:52.31.106.198 ip4:198.154.180.128/26 include:_spf_euwest1.prod.hydra.sophos.com include:spf.protection.outlook.com include:_spf.salesforce.com -all", "sophos-domain-verification=5a55f596b6463909245486932f2d5e27055b1bbf"]
}

resource "aws_route53_record" "icrir_route53_txt_info_sophos" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "sophos83abf2d0ead7485dac00fb38cd735dc7._domainkey.info.icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo563TjxFBPtVmo6CUHVlEomBFbX1Ts3H21/w42NR6uzNivz3OuekWWN+ifmVnE/YFx9QLSy/bsh/kMegWC7\"\"ac6806qKZkM7Cn8iqWhQdSZUJzNUXw5mFim49LPjKyUrMF0gNYma/Ent9BVgX1uk65jKJSi0/DwZvk1Q5pGJb8J+DhWwAuh8Xmckc8fTd7j3N0\"\"Ip27Jw43SJXkOsimhfF3/6UU7JfN+dr2tRNtTA8r2E6JWupngMXvjpLvun03WAxZm/otdFWQiZvOnRDAJs3hHSDU9kNdCvdFz0zh9nqSAJDKibYR0IE2EFzbjk1ZwYSKYOu5qsCuLDWC4G+5bcNDQIDAQAB"]
}

resource "aws_route53_record" "icrir_route53_txt_info_dmarc" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "_dmarc.info.icrir.independent-inquiry.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=reject; rua=mailto:dmarc-rua@finance-ni.gov.uk,mailto:dmarcrua@dmarc.service.gov.uk; adkim=r; aspf=r; pct=100"]
}

resource "aws_route53_record" "icrir_route53_mx" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "icrir.independent-inquiry.uk"
  type    = "MX"
  ttl     = "300"
  records = ["10 mx-01-eu-west-1.prod.hydra.sophos.com", "20 mx-02-eu-west-1.prod.hydra.sophos.com"]
}

resource "aws_route53_record" "icrir_route53_mx_careers" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "eploymail.careers.icrir.independent-inquiry.uk"
  type    = "MX"
  ttl     = "300"
  records = ["10 feedback-smtp.eu-west-2.amazonses.com"]
}

resource "aws_route53_record" "icrir_route53_mx_info" {
  zone_id = aws_route53_zone.icrir_route53_zone.zone_id
  name    = "info.icrir.independent-inquiry.uk"
  type    = "MX"
  ttl     = "300"
  records = ["10 mx-01-eu-west-1.prod.hydra.sophos.com", "20 mx-02-eu-west-1.prod.hydra.sophos.com"]
}
