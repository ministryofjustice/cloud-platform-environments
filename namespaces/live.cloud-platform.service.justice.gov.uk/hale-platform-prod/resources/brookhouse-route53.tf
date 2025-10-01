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
  records = ["0, ."]
}

resource "aws_route53_record" "brookhouse_route53_txt" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["E0G0S16406", "google-site-verification=yzqA25_KO_rZYL4b-UxXDXI7x-ZWUKYHjtyxyVILvqU", "adobe-idp-site-verification=12745d082f0122d00a6ac369ec9edff9a2b54fd6e569dee485e26119cd5523ee", "dn0QxuQ4AjkLbhQTyFA+nWix2yM5DE7xy0qbZgb1afVWAT/TcyzyZQOq7xkIsvcroCHw8YuEw/pw2JQGJMaZQQ==", "QuoVadis=22879b0e-362c-40bc-a726-da94acee34ed", "v=spf1 -all"]
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
  records = ["v=DMARC1;p=reject;rua=mailto:ukho@rua.agari-eu.com; ruf=mailto:ukho@ruf.agari-eu.com"]
}

resource "aws_route53_record" "brookhouse_route53_txt_dkim" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "*._domainkey.brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; p="]
}

resource "aws_route53_record" "brookhouse_route53_txt_pki" {
  zone_id = aws_route53_zone.brookhouse_route53_zone.zone_id
  name    = "_pki-validation.brookhouseinquiry.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["A736-F07F-B9BC-9593-19E1-3ED8-17BB-9F45"]
}
