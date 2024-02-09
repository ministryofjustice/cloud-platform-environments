resource "aws_route53_zone" "newfuturesnetwork_route53_zone" {
  name = "newfuturesnetwork.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "newfuturesnetwork_route53_zone_sec" {
  metadata {
    name      = "newfuturesnetwork-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.newfuturesnetwork_route53_zone.zone_id
  }
}

resource "aws_route53_record" "newfuturesnetwork_route53_a_record_main" {
  zone_id = aws_route53_zone.newfuturesnetwork_route53_zone.zone_id
  name    = "newfuturesnetwork.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["35.214.109.137"]
}

resource "aws_route53_record" "newfuturesnetwork_route53_a_record_main_www" {
  zone_id = aws_route53_zone.newfuturesnetwork_route53_zone.zone_id
  name    = "www.newfuturesnetwork.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["35.214.109.137"]
}

resource "aws_route53_record" "newfuturesnetwork_route53_aaaa_record_main" {
  zone_id = aws_route53_zone.newfuturesnetwork_route53_zone.zone_id
  name    = "newfuturesnetwork.gov.uk"
  type    = "AAAA"
  ttl     = "300"
  records = ["2a07:7800::124"]
}

resource "aws_route53_record" "newfuturesnetwork_route53_mx_record_main" {
  zone_id = aws_route53_zone.newfuturesnetwork_route53_zone.zone_id
  name    = "newfuturesnetwork.gov.uk"
  type    = "MX"
  ttl     = "3600"
  records = ["10 mx.stackmail.com"]
}

resource "aws_route53_record" "newfuturesnetwork_route53_txt_record_main" {
  zone_id = aws_route53_zone.newfuturesnetwork_route53_zone.zone_id
  name    = "newfuturesnetwork.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["facebook-domain-verification=rj96j5tuxvn74i1oflm627ohw7kecr", "mr9p63p9itcc85kj0p46h4r9il"]
}

resource "aws_route53_record" "newfuturesnetwork_route53_txt_record_asvdns" {
  zone_id = aws_route53_zone.newfuturesnetwork_route53_zone.zone_id
  name    = "_asvdns-d9a8f646-b712-4174-85fb-fc940cfd0d52.newfuturesnetwork.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_6273e879-9aa2-46c4-8dd7-5815695f715f"]
}

resource "aws_route53_record" "newfuturesnetwork_route53_txt_record_dmarc" {
  zone_id = aws_route53_zone.newfuturesnetwork_route53_zone.zone_id
  name    = "_dmarc.newfuturesnetwork.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DMARC1;p=none;sp=none;rua=mailto:dmarc-rua@dmarc.service.gov.uk"]
}

resource "aws_route53_record" "newfuturesnetwork_route53_txt_record_smtp" {
  zone_id = aws_route53_zone.newfuturesnetwork_route53_zone.zone_id
  name    = "_smtp._tls.newfuturesnetwork.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}