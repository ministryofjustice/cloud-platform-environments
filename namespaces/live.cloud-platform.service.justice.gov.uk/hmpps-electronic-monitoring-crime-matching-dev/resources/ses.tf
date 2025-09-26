# Domain Identity Setup
resource "aws_ses_domain_identity" "crime_matching_domain" {
  domain = var.domain
}

resource "aws_ses_domain_identity_verification" "crime_matching_verification" {
  domain     = aws_ses_domain_identity.crime_matching_domain.id
  depends_on = [aws_route53_record.crime_matching_amazonses_verification_record]
}

resource "aws_route53_record" "crime_matching_amazonses_verification_record" {
  zone_id = aws_route53_zone.crime_matching_route53_zone.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.crime_matching_domain.verification_token]
}

# MX Setup for receiving emails
resource "aws_route53_record" "crime_matching_amazonses_mx" {
  zone_id  = aws_route53_zone.crime_matching_route53_zone.zone_id
  name     = var.domain
  type     = "MX"
  ttl      = "600"
  records  = ["10 inbound-smtp.eu-west-2.amazonaws.com"]
}

# SES Receipt Rules to define actions when email is ingested
resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "email-ingestion-rules"
}

resource "aws_ses_receipt_rule" "store_email" {
  name          = "store-in-s3"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  recipients    = ["crime-csv@${var.domain}"]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name       = aws_s3_bucket.s3_email_bucket.id
    object_key_prefix = "crime-data/"
    position          = 1
  }
}

# Activate rule set
resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
}
