resource "aws_acm_certificate" "apigw_custom_hostname" {
  domain_name       = "${var.hostname}.${var.base_domain}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "apigw_custom_hostname" {
  certificate_arn = aws_acm_certificate.apigw_custom_hostname.arn
}
