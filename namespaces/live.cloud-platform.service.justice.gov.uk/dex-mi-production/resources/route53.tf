resource "aws_route53_zone" "route53_zone" {
  name = "cdpt-metabase.service.justice.gov.uk"

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

resource "aws_route53_record" "metabase_domain_amazonses_verification_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "_amazonses.cdpt-metabase.service.justice.gov.uk"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.metabase_domain.verification_token]
}

resource "aws_route53_record" "metabase_domain_amazonses_dkim_record" {
  count   = 3
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "${element(aws_ses_domain_dkim.metabase_domain_dkim.dkim_tokens, count.index)}._domainkey.cdpt-metabase.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.metabase_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
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
