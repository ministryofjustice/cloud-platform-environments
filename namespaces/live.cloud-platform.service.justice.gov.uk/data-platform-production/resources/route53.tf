resource "aws_route53_zone" "data_platform_production_route53_zone" {
  name = "data-platform.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "data_platform_production_route53_zone_id" {
  metadata {
    name      = "cloud-platform-data-platform-production-route53-zone-id"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  }
}

resource "aws_route53_record" "data_platform_technical_documentation" {
  zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  name    = "technical-documentation.data-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["ministryofjustice.github.io."]
}

resource "aws_route53_record" "data_platform_pagerduty_status_page_web" {
  zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  name    = "status.data-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["cd-4a9d4d61b9ba517b444f76f11a406278.hosted-status.pagerduty.com."]
}

resource "aws_route53_record" "data_platform_pagerduty_status_page_web_tls_validation" {
  zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  name    = "_701f6977b827d5ad23c4f98802a51bc3.status.data-platform.service.justice.gov.uk."
  type    = "CNAME"
  ttl     = "300"
  records = ["_56473aa9b1f7b9aec52ac3d3ea416721.yygwskclfy.acm-validations.aws."]
}

resource "aws_route53_record" "data_platform_pagerduty_status_page_mail" {
  zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  name    = "em9648.status.data-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u31181182.wl183.sendgrid.net."]
}

resource "aws_route53_record" "data_platform_pagerduty_status_page_mail_dkim1" {
  zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  name    = "pdt._domainkey.status.data-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["pdt.domainkey.u31181182.wl183.sendgrid.net."]
}

resource "aws_route53_record" "data_platform_pagerduty_status_page_mail_dkim2" {
  zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  name    = "pdt2._domainkey.status.data-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["pdt2.domainkey.u31181182.wl183.sendgrid.net."]
}

resource "aws_route53_record" "data_platform_rapid_dev_zone" {
  zone_id = aws_route53_zone.data_platform_production_route53_zone.zone_id
  name    = "rapid.dev.data-platform.service.justice.gov.uk"
  type    = "NS"
  ttl     = "600"
  records = ["ns-1638.awsdns-12.co.uk.", "ns-93.awsdns-11.com.", "ns-1512.awsdns-61.org.", "ns-588.awsdns-09.net."]
}
