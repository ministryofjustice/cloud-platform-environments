resource "aws_acm_certificate" "frontend" {
  count = var.use_custom_certificate ? 1 : 0

  domain_name       = var.cloudfront_alias
  validation_method = "DNS"

  tags = merge(var.tags, {
    Name = "${var.environment}-frontend-certificate"
  })

  provider = aws.virginia

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "frontend" {
  count = var.use_custom_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.frontend[0].arn
  validation_record_fqdns = aws_route53_record.cert_validations[*].fqdn

  provider = aws.virginia

  timeouts {
    create = "10m"
  }

  depends_on = [
    aws_acm_certificate.frontend,
    aws_route53_record.cert_validations,
  ]
}
