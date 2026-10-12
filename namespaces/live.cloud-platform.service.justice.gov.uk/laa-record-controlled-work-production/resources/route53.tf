resource "aws_route53_zone" "record_controlled_work" {
  name = var.domain
}

resource "kubernetes_secret" "route53_zone_output" {
  metadata {
    name      = "rcw-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.record_controlled_work.zone_id
    nameservers = join("\n", aws_route53_zone.record_controlled_work.name_servers)
  }
}

resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.record_controlled_work.zone_id
  name    = var.domain
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 -all"]
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.record_controlled_work.zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = 300
  records = ["v=DMARC1;p=reject;rua=mailto:dmarc-rua@dmarc.service.gov.uk;"]
}

resource "aws_route53_record" "dkim" {
  zone_id = aws_route53_zone.record_controlled_work.zone_id
  name    = "*._domainkey.${var.domain}"
  type    = "TXT"
  ttl     = 300
  records = ["v=DKIM1; p="]
}

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.record_controlled_work.zone_id
  name    = var.domain
  type    = "MX"
  ttl     = 3600
  records = ["0 ."]
}
