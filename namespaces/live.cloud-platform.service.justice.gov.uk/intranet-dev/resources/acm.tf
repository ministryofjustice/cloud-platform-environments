# CloudFront alias certificate.

# resource "aws_acm_certificate" "cloudfront_alias_cert" {
#   domain_name       = var.cloudfront_alias
#   validation_method = "DNS"

#   tags = {
#     business-unit          = var.business_unit
#     application            = var.application
#     is-production          = var.is_production
#     environment-name       = var.environment
#     owner                  = var.team_name
#     infrastructure-support = var.infrastructure_support
#     namespace              = var.namespace
#     team_name              = var.team_name
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# CloudFront alias certificate validation.

# resource "aws_acm_certificate_validation" "cloudfront_alias_cert_validation" {
#   certificate_arn         = aws_acm_certificate.cloudfront_alias_cert.arn
#   validation_record_fqdns = aws_route53_record.cert-validations[*].fqdn 

#   timeouts {
#     create = "10m"
#   }

#   depends_on = [aws_route53_record.cert-validations]
# }
