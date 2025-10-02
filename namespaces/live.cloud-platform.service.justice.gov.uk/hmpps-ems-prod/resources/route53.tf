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
  name    = "mapping.teac.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-1620.awsdns-10.co.uk.", "ns-446.awsdns-55.com.", "ns-1123.awsdns-12.org.", "ns-606.awsdns-11.net."]
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

########################
# RUBY (Telephony G4S) #
########################

# ACM Validation Record (Preprod)
resource "aws_route53_record" "ruby_preprod_dns_validation_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_f32f12ae73a733d24edd43c85757d18b.ruby.preprod.electronic-monitoring.service.justice.gov.uk."
  type    = "CNAME"
  ttl     = "7200"
  records = ["_48d1a9b6ff3eb34ffef392d38d9b1d65.hnyzmxtzsz.acm-validations.aws."]
}

# API Gateway alias record (Preprod)
resource "aws_route53_record" "ruby_preprod_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "ruby.preprod.electronic-monitoring.service.justice.gov.uk"
  type    = "A"

  alias {
    name                   = "d-t99nlc7pcd.execute-api.eu-west-2.amazonaws.com."
    zone_id                = "ZJ5UAJN8Y3Z2Q"
    evaluate_target_health = false
  }
}

# ACM Validation Record (Prod)
resource "aws_route53_record" "ruby_prod_dns_validation_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_c7c996bb788c4319fe5574b3456c85c5.ruby.electronic-monitoring.service.justice.gov.uk."
  type    = "CNAME"
  ttl     = "7200"
  records = ["_0966f119a76d9832601afe2332cf0b9d.kmjqhnbgnp.acm-validations.aws."]
}

# API Gateway alias record (Prod)
resource "aws_route53_record" "ruby_prod_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "ruby.electronic-monitoring.service.justice.gov.uk"
  type    = "A"

  alias {
    name                   = "d-oylazfufm6.execute-api.eu-west-2.amazonaws.com"
    zone_id                = "ZJ5UAJN8Y3Z2Q"
    evaluate_target_health = false
  }
}

#######################
# EMAC Data Ingestion #
#######################

resource "aws_route53_record" "hmpps_crime_matching_zone" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "crime-matching.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-1148.awsdns-15.org.", "ns-1782.awsdns-30.co.uk.", "ns-27.awsdns-03.com.", "ns-654.awsdns-17.net."]
}