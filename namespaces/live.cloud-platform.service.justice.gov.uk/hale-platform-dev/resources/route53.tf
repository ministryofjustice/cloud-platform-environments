resource "aws_route53_zone" "websitebuilder__dev_route53_zone" {
  name = "dev.websitebuilder.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

data "kubernetes_secret" "route53_zone_output" {
  metadata {
    name      = "websitebuilder-route53-zone-output"
    namespace = "hale-platform-prod"
  }
}

# Delegate dev. to the child zone's NS set
resource "aws_route53_record" "delegate_dev_to_child" {
  zone_id = data.kubernetes_secret.route53_zone_output.data["zone_id"]
  name    = "dev"  # or "dev.websitebuilder.service.justice.gov.uk."
  type    = "NS"
  ttl     = 172800

  records = aws_route53_zone.websitebuilder__dev_route53_zone.name_servers
}

resource "kubernetes_secret" "websitebuilder_route53_zone" {
  metadata {
    name      = "websitebuilder-dev-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.websitebuilder__dev_route53_zone.zone_id
  }
}


# Create an A record in the hosted zone for the CloudFront alias.
# Note, the zone_id parameter is set to the zone_id from the hale-platform-prod kubernetes secret.
# And the alias.zone_id parameter is set to the CloudFront hosted zone id.


resource "aws_route53_record" "data" {
  zone_id = aws_route53_zone.websitebuilder__dev_route53_zone.zone_id
  name    = var.cloudfront_alias
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = module.cloudfront.cloudfront_url
    zone_id                = module.cloudfront.cloudfront_hosted_zone_id
  }
}

# Apex alias: dev.websitebuilder.service.justice.gov.uk → ALB
resource "aws_route53_record" "dev_apex_alias" {
  zone_id = aws_route53_zone.websitebuilder__dev_route53_zone.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = "a7a824c08f436470ea14bfc9039e7e40-de8c3f9bc19bdbd1.elb.eu-west-2.amazonaws.com."
    zone_id                = "ZD4D7Y8KGAS4G"
    evaluate_target_health = false
  }
}

# In acm.tf, an aws_acm_certificate resource is created for the CloudFront alias.
# As the validation method is set to DNS, a route53 record is created here for the certificate validation.

resource "aws_route53_record" "cert_validations" {
  count           = length(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options)

  zone_id         = aws_route53_zone.websitebuilder__dev_route53_zone.zone_id

  name            = element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_name, count.index)
  type            = element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_type, count.index)
  records         = [element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_value, count.index)]
  ttl             = 60
  allow_overwrite = true

}