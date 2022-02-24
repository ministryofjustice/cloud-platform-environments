resource "aws_route53_zone" "route53_zone" {
  name = var.domain

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_route53_record" "grafana_platform_amazonses_verification_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_amazonses.grafana.platform.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.grafana_platform.verification_token]
}

resource "aws_route53_record" "grafana_platform_amazonses_dkim_record" {
  count   = 3
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "${element(aws_ses_domain_dkim.grafana_platform.dkim_tokens, count.index)}._domainkey.grafana.platform.${var.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.grafana_platform.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "hmpps_ems_mapping_dev_zone" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "mapping.dev.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-1001.awsdns-61.net.", "ns-1963.awsdns-53.co.uk.", "ns-376.awsdns-47.com.", "ns-1139.awsdns-14.org."]
}

resource "aws_route53_record" "hmpps_ems_mapping_test_zone" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "mapping.test.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-745.awsdns-29.net.", "ns-1943.awsdns-50.co.uk.", "ns-318.awsdns-39.com.", "ns-1433.awsdns-51.org."]
}

resource "aws_route53_record" "hmpps_ems_mapping_training_zone" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "mapping.training.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-867.awsdns-44.net.", "ns-1635.awsdns-12.co.uk.", "ns-412.awsdns-51.com.", "ns-1419.awsdns-49.org."]
}

resource "aws_route53_record" "hmpps_ems_mapping_preprod_zone" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "mapping.pp.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-736.awsdns-28.net.", "ns-1564.awsdns-03.co.uk.", "ns-293.awsdns-36.com.", "ns-1090.awsdns-08.org."]
}

resource "aws_route53_record" "hmpps_ems_mapping_prod_zone" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "mapping.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-785.awsdns-34.net.", "ns-1610.awsdns-09.co.uk.", "ns-230.awsdns-28.com.", "ns-1150.awsdns-15.org."]
}

resource "aws_route53_record" "hmpps_ems_tagging_test_zone" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "tagging.test.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-788.awsdns-34.net.", "ns-1858.awsdns-40.co.uk.", "ns-70.awsdns-08.com.", "ns-1045.awsdns-02.org."]
}

resource "aws_route53_record" "hmpps_ems_tagging_preprod_zone" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "tagging.pp.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-967.awsdns-56.net.", "ns-1745.awsdns-26.co.uk.", "ns-153.awsdns-19.com.", "ns-1180.awsdns-19.org."]
}

resource "aws_route53_record" "hmpps_ems_tagging_prod_zone" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "tagging.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-1017.awsdns-63.net.", "ns-1682.awsdns-18.co.uk.", "ns-428.awsdns-53.com.", "ns-1300.awsdns-34.org."]
}

resource "aws_route53_record" "auth0_platform_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "auth.platform.${var.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["moj-hmpps-ems-platform-auth-cd-trhmgjuqwolmosso.edge.tenants.eu.auth0.com"]
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_zone.zone_id
  }
}
