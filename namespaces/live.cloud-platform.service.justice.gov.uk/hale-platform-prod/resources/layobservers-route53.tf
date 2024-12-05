resource "aws_route53_zone" "layobservers_route53_zone" {
  name = "layobservers.org"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "layobservers_route53_zone_sec" {
  metadata {
    name      = "layobservers-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.layobservers_route53_zone.zone_id
  }
}

resource "aws_route53_record" "layobservers_route53_cname_record_acm" {
  zone_id = aws_route53_zone.layobservers_route53_zone.zone_id
  name    = "_2dc0af1e023810b4729e89f34abdf9eb.layobservers.org"
  type    = "CNAME"
  ttl     = "60"
  records = ["_194cf57417dad1e38615934d3d027307.auiqqraehs.acm-validations.aws."]
}

resource "aws_route53_record" "layobservers_route53_cname_www_record_acm" {
  zone_id = aws_route53_zone.layobservers_route53_zone.zone_id
  name    = "_8e030d99adf836af6e7c0300c6f71984.www.layobservers.org"
  type    = "CNAME"
  ttl     = "60"
  records = ["_751d601494e39d5ea435d080d888b065.auiqqraehs.acm-validations.aws."]
}

resource "aws_route53_record" "layobservers_route53_txt_record_main" {
  zone_id = aws_route53_zone.layobservers_route53_zone.zone_id
  name    = "_dmarc.layobservers.org"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=reject; sp=reject; rua=mailto:dmarc-rua@dmarc.service.gov.uk;"]
}
