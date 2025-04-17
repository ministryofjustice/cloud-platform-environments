resource "aws_ses_domain_identity" "metabase_domain" {
  domain = "cdpt-metabase.service.justice.gov.uk"
}

resource "aws_ses_domain_identity_verification" "metabase_domain_identity" {
  domain     = aws_ses_domain_identity.metabase_domain.id
  depends_on = [aws_route53_record.metabase_domain_amazonses_verification_record]
}

resource "aws_ses_domain_dkim" "metabase_domain_dkim" {
  domain = aws_ses_domain_identity.metabase_domain.domain
}
