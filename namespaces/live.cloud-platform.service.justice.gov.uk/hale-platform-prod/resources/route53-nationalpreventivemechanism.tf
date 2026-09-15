resource "aws_route53_zone" "nationalpreventivemechanism_route53_zone" {
  name = "nationalpreventivemechanism.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "nationalpreventivemechanism_route53_zone_sec" {
  metadata {
    name      = "npm-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  }
}

resource "aws_route53_record" "nationalpreventivemechanism_route53_mx_record_smtp" {
  zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  name    = "nationalpreventivemechanism.org.uk"
  type    = "MX"
  ttl     = "60"
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}

resource "aws_route53_record" "nationalpreventivemechanism_route53_txt_record_amazonses" {
  zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  name    = "_amazonses.nationalpreventivemechanism.org.uk"
  type    = "TXT"
  ttl     = "60"
  records = ["E2TgLGMdRe0Mm6FlJHvz1FuDrRTRhlHIZlnRTGJ58iQ="]
}

resource "aws_route53_record" "nationalpreventivemechanism_route53_txt_record_dmarc" {
  zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  name    = "_dmarc.nationalpreventivemechanism.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1;p=reject;sp=reject;rua=mailto:dmarc-rua@dmarc.service.gov.uk;"]
}