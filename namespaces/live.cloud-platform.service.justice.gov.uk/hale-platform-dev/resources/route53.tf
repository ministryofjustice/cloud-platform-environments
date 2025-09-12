# Get the kubernetes secret 'route53-zone-output' from hale-platform-prod namespace.
# This secret contains the zone_id of the hosted zone.

data "kubernetes_secret" "route53_zone_output" {
  metadata {
    name      = "websitebuilder-route53-zone-output"
    namespace = "hale-platform-prod"
  }
}

# Create an A record in the hosted zone for the CloudFront alias.
# Note, the zone_id parameter is set to the zone_id from the hale-platform-prod kubernetes secret.
# And the alias.zone_id parameter is set to the CloudFront hosted zone id.


resource "aws_route53_record" "data" {
  zone_id = data.kubernetes_secret.route53_zone_output.data["zone_id"]
  name    = var.cloudfront_alias
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = module.cloudfront.cloudfront_url
    zone_id                = module.cloudfront.cloudfront_hosted_zone_id
  }
}

# In acm.tf, an aws_acm_certificate resource is created for the CloudFront alias.
# As the validation method is set to DNS, a route53 record is created here for the certificate validation.

resource "aws_route53_record" "cert_validations" {
  count           = length(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options)

  zone_id         = data.kubernetes_secret.route53_zone_output.data["zone_id"]

  name            = element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_name, count.index)
  type            = element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_type, count.index)
  records         = [element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_value, count.index)]
  ttl             = 60
  allow_overwrite = true
}