resource "aws_route53_zone" "brookhouse_route53_zone" {
  name = "brookhouseinquiry.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "brookhouse_route53_zone_sec" {
  metadata {
    name      = "brookhouse-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  }
}

resource "aws_route53_record" "brookhouse_route53_mx_record_mail" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "brookhouseinquiry.org.uk"
  type    = "MX"
  ttl     = "3600"
  records = ["10 mail1.brookhouseinquiry.org.uk", "10 mail2.brookhouseinquiry.org.uk", "10 mail3.brookhouseinquiry.org.uk", "10 mail4.brookhouseinquiry.org.uk"]
}

resource "aws_route53_record" "brookhouse_route53_a_record_mail1" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "mail1.brookhouseinquiry.org.uk"
  type    = "A"
  ttl     = "300"
  records = ["18.168.37.156"]
}

resource "aws_route53_record" "brookhouse_route53_a_record_mail2" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "mail2.brookhouseinquiry.org.uk"
  type    = "A"
  ttl     = "300"
  records = ["18.168.37.157"]
}

resource "aws_route53_record" "brookhouse_route53_a_record_mail3" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "mail3.brookhouseinquiry.org.uk"
  type    = "A"
  ttl     = "300"
  records = ["18.168.37.158"]
}

resource "aws_route53_record" "brookhouse_route53_a_record_mail4" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "mail4.brookhouseinquiry.org.uk"
  type    = "A"
  ttl     = "300"
  records = ["18.168.37.159"]
}

resource "aws_route53_record" "brookhouse_route53_txt" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["E0G0S16406", "MS=ms51271079", "google-site-verification=yzqA25_KO_rZYL4b-UxXDXI7x-ZWUKYHjtyxyVILvqU", "adobe-idp-site-verification=12745d082f0122d00a6ac369ec9edff9a2b54fd6e569dee485e26119cd5523ee", "dn0QxuQ4AjkLbhQTyFA+nWix2yM5DE7xy0qbZgb1afVWAT/TcyzyZQOq7xkIsvcroCHw8YuEw/pw2JQGJMaZQQ==", "QuoVadis=22879b0e-362c-40bc-a726-da94acee34ed", "v=spf1 include:u2320754.wl005.sendgrid.net ip4:18.168.37.156/30 -all"]
}

resource "aws_route53_record" "brookhouse_route53_txt_asvdns" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "_asvdns-025c0250-54d2-47b0-82ab-aa324c257fd9.brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_d967771e-375c-4af1-91e5-7d36b30b69de"]
}

resource "aws_route53_record" "brookhouse_route53_txt_dmarc" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "_dmarc.brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1;p=reject;sp=reject;rua=mailto:dmarc-rua@dmarc.service.gov.uk"]
}

resource "aws_route53_record" "brookhouse_route53_txt_dkim" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "08032021._domainkey.brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDQq1FyQaOs1If2qMDgFcPzoSPxgrW74N5sDgnGe0n4lHdZeuQK9TbSvGXsadobFHsdYi9TaRs7ZcTSXF2YutzPlKYXl1owqP81UpPHB9mdsGoIZpgVqdWvVm+lRwk8KtKXqUh84norLAZveWkWNlfEPwr8Rl7O+QcVYUEln3DCSwIDAQAB;"]
}

resource "aws_route53_record" "brookhouse_route53_txt_dkim_everyone" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "everyone._domainkey.brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDXkYQfwfJJZ+f8aUiS06jOhupWFHRwkL890axNTiJUPRhGZ+y6KHABwyXf06lR8CXzY20pwwy4j5vvQePMgvQbS7AkjhpiKK9O3kSX/KJ6GJ6zpgFO4Bhnq8eRYyBWuy1BZT+HNB5eoytxsUuXi0dmCWmq/rTBEYQMO/kCaWqJWQIDAQAB;"]
}

resource "aws_route53_record" "brookhouse_route53_txt_dkim_07092023" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "07092023._domainkey.brookhouseinquiry.org.uk."
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; t=s; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApFBvkc4d43rDfJNqF4PxbaTKY3j6hfLVcPrF5TC4IdvHvhMLRE0QSbLi/nJLXskM0MM0ClSUlnPV16HahDgkQdSwRc3nZleV2KqO2fKLdRque2ddG7K\"\"+huY9IvAtyqPD9CeCxuxXeakVYFqUYUyM5uhPoDrtQsHT2lhZ/faAN/e6FpdtBbOIpxiITbuZxanaWaTcn3GoN/A0RWHt0LeLpitU23tepDbysfuZFk7ZCc+qhNKUL+rNd5yWeaHHbs4Ge1KH6rMN7pXgHUMpvNl8YMIR2I1OvTz/R3IKn6M73MdUV8vlgjsdrZ4s+jOYUCBxQL3ukc+ogfWy9babqxgtaQIDAQAB;"]
}

resource "aws_route53_record" "brookhouse_route53_txt_mta" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "_mta-sts.brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=STSv1; id=20230517"]
}

resource "aws_route53_record" "brookhouse_route53_txt_pki" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "_pki-validation.brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["A736-F07F-B9BC-9593-19E1-3ED8-17BB-9F45"]
}

resource "aws_route53_record" "brookhouse_route53_txt_smtp" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "_smtp._tls.brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "brookhouse_route53_cname_record_sendgrid" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "2320754.brookhouseinquiry.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["sendgrid.net"]
}

resource "aws_route53_record" "brookhouse_route53_cname_record_sendgrid_s1" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "s1._domainkey.brookhouseinquiry.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["s1.domainkey.u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "brookhouse_route53_cname_record_sendgrid_s2" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "s2._domainkey.brookhouseinquiry.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["s2.domainkey.u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "brookhouse_route53_cname_record_acm" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "_e57d0720ad46276ca2a572c43912bedc.brookhouseinquiry.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_e7da7ae1e84203be7e4bb6234aeee9b1.vhzmpjdqfx.acm-validations.aws."]
}

resource "aws_route53_record" "brookhouse_route53_cname_record_acm2" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "_f63865701a7be4d622b24ca3482db76a.www.brookhouseinquiry.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_892201baf53507ab667e456b004e6ff0.nhqijqilxf.acm-validations.aws."]
}

resource "aws_route53_record" "brookhouse_route53_cname_record_sendgrid_em" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "em6348.brookhouseinquiry.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u2320754.wl005.sendgrid.net"]
}

resource "aws_route53_record" "brookhouse_route53_cname_record_mta" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "mta-sts.brookhouseinquiry.org.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["orange-moss-0229de303.3.azurestaticapps.net"]
}

resource "aws_route53_record" "brookhouse_route53_cname_record_sendgrid_url" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "url6609.brookhouseinquiry.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["sendgrid.net"]
}

resource "aws_route53_record" "brookhouse_route53_srv_record_autodiscover" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "_autodiscover._tcp.brookhouseinquiry.org.uk"
  type    = "SRV"
  ttl     = "3600"
  records = ["10 10 443 autodiscover.homeoffice.gov.uk"]
}
