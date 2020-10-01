resource "aws_ses_domain_identity" "grafana_platform" {
  provider = aws.ireland
  domain   = "grafana.platform.${var.domain}"
}

resource "aws_ses_domain_identity_verification" "grafana_platform" {
  provider   = aws.ireland
  domain     = aws_ses_domain_identity.grafana_platform.id
  depends_on = [aws_route53_record.grafana_platform_amazonses_verification_record]
}

resource "aws_ses_domain_dkim" "grafana_platform" {
  provider = aws.ireland
  domain   = aws_ses_domain_identity.grafana_platform.domain
}