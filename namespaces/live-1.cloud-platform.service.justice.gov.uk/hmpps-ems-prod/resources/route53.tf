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

# # Acquisitive Crime Production
# resource "aws_route53_record" "hmpps_ems_ac_prod_zone" {
#   zone_id = aws_route53_zone.route53_zone.zone_id
#   name    = "acquisitive-crime.${var.domain}"
#   type    = "NS"
#   ttl     = "600"
#   records = ["TBC", "TBC", "TBC", "TBC"]
# }

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_zone.zone_id
  }
}
